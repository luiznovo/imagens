# Build base
FROM --platform=$TARGETOS/$TARGETARCH node:lts-bookworm-slim

LABEL author="Luiz" maintainer="luiz@gratian.pro"

# Cria um usuário limitado para rodar o container
RUN useradd -m -d /home/container container
USER container
WORKDIR /home/container

# Configura sinal de parada
STOPSIGNAL SIGINT

# Instala pacotes básicos de sistema que podem ser úteis
RUN sudo apt update && sudo apt -y install \
    ffmpeg \
    git \
    curl \
    build-essential \
    iproute2 \
    tzdata \
    zip \
    tar \
    tini \
    && sudo rm -rf /var/lib/apt/lists/*

# Instala npm, pnpm e ferramentas de typescript globalmente
RUN npm install --global npm@latest typescript ts-node @types/node \
    && npm install -g corepack \
    && corepack enable \
    && corepack prepare pnpm@latest --activate

# Copia entrypoint
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define variáveis de ambiente
ENV USER=container HOME=/home/container

# Usa tini como init process
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
