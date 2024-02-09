# ecosystem-chat
Implantação Traefik + Portainer + Postgres + Minio + Redis + Chatwoot + N8N + Evolution API (White Label)


# Instalação Automatizada da Infraestrutura Docker

Este guia fornece instruções para usar um script Bash que automatiza a instalação e configuração de uma infraestrutura Docker em um servidor Ubuntu 22.04. O script configura o ambiente para executar Docker, Docker Swarm, Traefik, Portainer e PostgreSQL.

## Pré-requisitos

- Ubuntu 22.04
- Acesso root ou privilégios sudo
- Conexão com a internet

## Uso

1. Clone o repositório ou baixe o script `implantacao.sh` para o seu servidor.
2. Certifique-se de que o script é executável: `chmod +x implantacao.sh`
3. Execute o script como root ou com sudo: `sudo ./implantacao.sh`




## Passos Implementados no Script

1. **Atualização do Sistema e Instalação do apparmor-utils**
- Atualiza a lista de pacotes do sistema.
- Instala o `apparmor-utils`.

2. **Configuração do Hostname**
- Define o hostname do servidor com base em uma variável definida no arquivo `.env`.

3. **Atualização do Arquivo /etc/hosts**
- Modifica o arquivo `/etc/hosts`, substituindo `127.0.0.1 localhost` por `127.0.0.1 NOME_SERVIDOR`.

4. **Instalação do Docker**
- Instala a versão mais recente do Docker utilizando o script de instalação disponibilizado pelo Docker.

5. **Inicialização do Docker Swarm**
- Inicializa o Docker em modo swarm.

6. **Criação de Rede Overlay**
- Cria uma rede overlay no Docker Swarm com base em uma variável definida no arquivo `.env`.

7. **Deploy da Stack Traefik**
- Realiza o deploy da stack Traefik utilizando o arquivo `traefik.yaml`.

8. **Deploy da Stack Portainer**
- Realiza o deploy da stack Portainer utilizando o arquivo `portainer.yaml`.

9. **Deploy da Stack PostgreSQL**
- Realiza o deploy da stack PostgreSQL utilizando o arquivo `postgres.yaml`.

## Customização

Para ajustar o script às suas necessidades específicas, você pode editar o arquivo `.env` para definir variáveis como `NOME_SERVIDOR` e `MINHA_REDE`, ou modificar os arquivos YAML (`traefik.yaml`, `portainer.yaml`, `postgres.yaml`) conforme necessário.

## Contribuições

Contribuições para o script são bem-vindas. Por favor, envie um pull request ou abra uma issue para discutir possíveis melhorias.

## Licença

Este script é fornecido sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
