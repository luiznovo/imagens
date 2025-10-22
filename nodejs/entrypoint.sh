#!/bin/bash
set -euo pipefail

cd /home/container || { echo "Erro: não foi possível acessar /home/container"; exit 1; }

# Torna o IP interno do Docker disponível para o processo
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Mostra a versão do Node.js
node -v

# Verifica se a variável STARTUP está definida
if [ -z "${STARTUP:-}" ]; then
    echo "Erro: a variável STARTUP não está definida."
    exit 1
fi

# Substitui placeholders {{VAR}} pela variável correspondente
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Verifica se o comando não tenta acessar diretórios fora de /home/container
if echo "$MODIFIED_STARTUP" | grep -q "\.\./"; then
    echo "Erro: path traversal detectado! Comando bloqueado."
    exit 1
fi

echo ":/home/container$ ${MODIFIED_STARTUP}"

# Executa o comando de forma segura
sh -c "$MODIFIED_STARTUP"
