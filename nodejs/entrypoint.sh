#!/bin/bash
set -euo pipefail

cd /home/container || { echo "Erro: não foi possível acessar /home/container"; exit 1; }

# Torna o IP interno do Docker disponível
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

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

# Executa o arquivo principal de forma segura
if [[ "$MAIN_FILE" == *.js ]]; then
    exec node "/home/container/$MAIN_FILE" ${NODE_ARGS:-}
else
    exec ts-node --esm "/home/container/$MAIN_FILE" ${NODE_ARGS:-}
fi
