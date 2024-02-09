#!/bin/bash

# Certifique-se de que o script está sendo executado como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado como root" 1>&2
   exit 1
fi

# Carrega as variáveis de ambiente de um arquivo .env
if [ -f ".env" ]; then
    export $(cat .env | sed 's/#.*//g' | xargs)
else
    echo "Arquivo .env não encontrado!"
    exit 1
fi

# Atualiza os pacotes e instala o apparmor-utils
echo "Atualizando pacotes e instalando apparmor-utils..."
sudo apt-get update && sudo apt-get install -y apparmor-utils

# Configura o hostname conforme definido na variável NOME_SERVIDOR do arquivo .env
echo "Configurando o hostname para $NOME_SERVIDOR..."
sudo hostnamectl set-hostname $NOME_SERVIDOR

# Edita o arquivo /etc/hosts para substituir a linha do localhost com o NOME_SERVIDOR
echo "Atualizando o arquivo /etc/hosts..."
sudo sed -i "s/127.0.0.1 localhost/127.0.0.1 $NOME_SERVIDOR/g" /etc/hosts

# Instala o Docker
echo "Instalando Docker..."
curl -fsSL https://get.docker.com | bash

# Inicializa o Docker Swarm
echo "Inicializando Docker Swarm..."
sudo docker swarm init

# Cria a rede overlay utilizando a variável MINHA_REDE do arquivo .env
echo "Criando a rede overlay $MINHA_REDE..."
sudo docker network create --driver=overlay $MINHA_REDE

# Faz o deploy da stack Traefik com o arquivo traefik.yaml
echo "Fazendo deploy da stack Traefik..."
sudo docker stack deploy --prune --resolve-image always -c traefik.yaml traefik

# Faz o deploy da stack Portainer com o arquivo portainer.yaml
echo "Fazendo deploy da stack Portainer..."
sudo docker stack deploy --prune --resolve-image always -c portainer.yaml portainer

# Faz o deploy da stack PostgreSQL com o arquivo postgres.yaml
echo "Fazendo deploy da stack PostgreSQL..."
sudo docker stack deploy --prune --resolve-image always -c postgres.yaml postgres

# Adicione aqui mais comandos conforme necessário para configurar sua infraestrutura

echo "Instalação concluída com sucesso."

# Lembre-se de tornar o script executável com: chmod +x nome_do_script.sh
# E execute-o com: sudo ./nome_do_script.sh
