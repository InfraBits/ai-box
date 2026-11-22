FROM docker.io/library/python:3.15-alpine

# Runtime deps for Claude Code
RUN apk add --no-cache \
        bash curl ca-certificates git ripgrep libgcc libstdc++ \
        less procps jq openssh-client coreutils findutils grep sed tar \
        nodejs npm py3-pip poetry

# Unprivileged user
RUN adduser -D -u 1000 -s /bin/bash developer
USER developer
RUN mkdir -p /home/developer/.claude /home/developer/.codex
WORKDIR /home/developer

# Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Codex CLI
RUN npm install @openai/codex

# Disable runtime settings
ENV DISABLE_AUTOUPDATER=1 \
    USE_BUILTIN_RIPGREP=0 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CODEX_HOME=/home/developer/.codex \
    PATH=/home/developer/.local/bin:$PATH
