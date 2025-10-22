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
USER root
RUN apt update && apt -y install \
    ffmpeg \
    git \
    curl \
    build-essential \
    iproute2 \
    tzdata \
    zip \
    tar \
    tini \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Garante permissões corretas no home do container
RUN mkdir -p /home/container/.npm /home/container/.config /home/container/.npm-global \
    && chown -R container:container /home/container

# Define cache do npm e pasta de prefixo para o usuário container
ENV NPM_CONFIG_CACHE=/home/container/.npm
ENV NPM_CONFIG_PREFIX=/home/container/.npm-global
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH

# Instala npm, pnpm e ferramentas de typescript globalmente (como container)
USER container
RUN npm install -g npm@latest typescript ts-node @types/node \
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
