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

echo ====================================================================================
echo "AGUARDANDO CONTAINER POSTGRES"
echo ====================================================================================
# Define o nome ou parte do nome do container para busca
CONTAINER_NAME_POSTGRES="postgres"

# Tempo de espera entre as verificações (em segundos)
SLEEP_TIME=10

# Tempo máximo de espera para o container subir (em segundos)
MAX_WAIT=300

# Inicia contador de tempo
start_time=$(date +%s)

echo "Aguardando o container $CONTAINER_NAME_POSTGRES estar pronto..."

while :; do
    # Obtém o ID do container baseado no nome
    POSTGRES_CONTAINER=$(docker ps --filter name=$CONTAINER_NAME_POSTGRES -q)

    # Verifica se o container foi encontrado
    if [ ! -z "$POSTGRES_CONTAINER" ]; then
        echo "Container $CONTAINER_NAME_POSTGRES encontrado. Prosseguindo com a configuração..."
        break
    else
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        # Verifica se o tempo máximo de espera foi excedido
        if [ $elapsed_time -ge $MAX_WAIT ]; then
            echo "Tempo máximo de espera excedido. O container $CONTAINER_NAME_POSTGRES não está disponível."
            exit 1
        fi

        # Espera por um período antes da próxima verificação
        echo "Container $CONTAINER_NAME_POSTGRES ainda não está pronto. Aguardando..."
        sleep $SLEEP_TIME
    fi
done

echo ====================================================================================
# Executa os comandos SQL para criar os bancos de dados
echo "Criando bancos de dados..."
docker exec -i $POSTGRES_CONTAINER psql -U postgres <<EOF
CREATE DATABASE $DATABASE_CHATWOOT;
CREATE DATABASE $DATABASE_N8N;
EOF

echo "Bancos de dados criados com sucesso."

# Faz o deploy da stack MINIO com o arquivo minio.yaml
echo "Fazendo deploy da stack MINIO..."
sudo docker stack deploy --prune --resolve-image always -c minio.yaml minio

# Faz o deploy da stack REDIS com o arquivo redis.yaml
echo "Fazendo deploy da stack REDIS..."
sudo docker stack deploy --prune --resolve-image always -c redis.yaml redis

# Faz o deploy da stack N8N com o arquivo n8n.yaml
echo "Fazendo deploy da stack N8N..."
sudo docker stack deploy --prune --resolve-image always -c n8n.yaml n8n

# Faz o deploy da stack CHATWOOT com o arquivo chatwoot.yaml
echo "Fazendo deploy da stack CHATWOOT..."
sudo docker stack deploy --prune --resolve-image always -c chatwoot.yaml chatwoot

echo ====================================================================================
echo "AGUARDANDO CONTAINER CHATWOOT"
echo ====================================================================================
# Define o nome ou parte do nome do container para busca
CONTAINER_NAME="chatwoot_app"

# Tempo de espera entre as verificações (em segundos)
SLEEP_TIME=10

# Tempo máximo de espera para o container subir (em segundos)
MAX_WAIT=300

# Inicia contador de tempo
start_time=$(date +%s)

echo "Aguardando o container $CONTAINER_NAME estar pronto..."

while :; do
    # Obtém o ID do container baseado no nome
    CHATWOOT_CONTAINER=$(docker ps --filter name=$CONTAINER_NAME -q)

    # Verifica se o container foi encontrado
    if [ ! -z "$CHATWOOT_CONTAINER" ]; then
        echo "Container $CONTAINER_NAME encontrado. Prosseguindo com a configuração..."
        break
    else
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        # Verifica se o tempo máximo de espera foi excedido
        if [ $elapsed_time -ge $MAX_WAIT ]; then
            echo "Tempo máximo de espera excedido. O container $CONTAINER_NAME não está disponível."
            exit 1
        fi

        # Espera por um período antes da próxima verificação
        echo "Container $CONTAINER_NAME ainda não está pronto. Aguardando..."
        sleep $SLEEP_TIME
    fi
done
echo ====================================================================================



# Acessa o console do container e executa o comando para preparar o banco de dados
echo "Preparando o banco de dados do Chatwoot..."
docker exec -it $CHATWOOT_CONTAINER /bin/ash -c "bundle exec rails db:chatwoot_prepare"

echo "Banco de dados do Chatwoot preparado com sucesso."





# Adicione aqui mais comandos conforme necessário para configurar sua infraestrutura

echo "Instalação concluída com sucesso."

# Lembre-se de tornar o script executável com: chmod +x nome_do_script.sh
# E execute-o com: sudo ./nome_do_script.sh
