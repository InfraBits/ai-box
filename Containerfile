# Build stage: fetch tool binaries so installers, caches and build-only
# packages never reach the final image.
FROM docker.io/library/python:3.15-alpine AS fetch
ARG TARGETARCH
RUN apk add --no-cache bash curl jq libgcc libstdc++

# Claude Code (native musl binary)
RUN curl -fsSL https://claude.ai/install.sh | bash \
 && install -D -m 0755 "$(readlink -f /root/.local/bin/claude)" /out/claude

# Codex CLI (static musl binary from GitHub releases)
RUN case "${TARGETARCH:-$(uname -m)}" in \
        amd64|x86_64) arch=x86_64 ;; \
        arm64|aarch64) arch=aarch64 ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && mkdir -p /tmp/codex \
 && curl -fsSL "https://github.com/openai/codex/releases/latest/download/codex-${arch}-unknown-linux-musl.tar.gz" \
    | tar -xz -C /tmp/codex \
 && install -D -m 0755 /tmp/codex/codex* /out/codex

FROM docker.io/library/python:3.15-alpine

# Runtime deps for Claude Code + some extra tools
RUN apk add --no-cache \
        bash curl git ripgrep libgcc libstdc++ \
        less procps jq openssh-client coreutils findutils grep sed tar socat \
 && adduser -D -u 1000 -s /bin/bash developer \
 && install -d -o developer -g developer \
        /home/developer/.claude /home/developer/.codex /home/developer/.local/bin

COPY --from=fetch /out/claude /home/developer/.local/bin/claude
COPY --from=fetch /out/codex /usr/local/bin/codex
RUN pip install --no-cache-dir poetry

USER developer
WORKDIR /home/developer

# Disable runtime settings
ENV DISABLE_AUTOUPDATER=1 \
    USE_BUILTIN_RIPGREP=0 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CODEX_HOME=/home/developer/.codex \
    PATH=/home/developer/.local/bin:$PATH
