#!/bin/bash
set -euo pipefail

cd /home/container || { echo "Erro: não foi possível acessar /home/container"; exit 1; }

# Torna o IP interno do Docker disponível
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Corrige permissões do container e cache do npm
chown -R container:container /home/container
export NPM_CONFIG_CACHE=/home/container/.npm
export NPM_CONFIG_PREFIX=/home/container/.npm-global
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# Mostra a versão do Node.js
node -v

# Verifica se MAIN_FILE está definido
if [ -z "${MAIN_FILE:-}" ]; then
    echo "Erro: MAIN_FILE não está definido."
    exit 1
fi

# Evita path traversal
if echo "$MAIN_FILE" | grep -q "\.\./"; then
    echo "Erro: path traversal detectado! Comando bloqueado."
    exit 1
fi

# Mostra qual arquivo será executado
echo "Iniciando o app: $MAIN_FILE"

# Instala pacotes adicionais se definidos
if [ ! -z "${NODE_PACKAGES:-}" ]; then
    echo "Instalando pacotes extras: $NODE_PACKAGES"
    npm install $NODE_PACKAGES
fi

if [ ! -z "${UNNODE_PACKAGES:-}" ]; then
    echo "Removendo pacotes: $UNNODE_PACKAGES"
    npm uninstall $UNNODE_PACKAGES
fi

# Instala dependências do package.json se existir
if [ -f /home/container/package.json ]; then
    echo "Instalando dependências do package.json..."
    npm install --production
fi

# Executa o arquivo principal de forma segura
if [[ "$MAIN_FILE" == *.js ]]; then
    exec node "/home/container/$MAIN_FILE" ${NODE_ARGS:-}
else
    exec ts-node --esm "/home/container/$MAIN_FILE" ${NODE_ARGS:-}
fi
