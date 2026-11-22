#!/usr/bin/env sh
set -eu
podman build -t infrabits/ai-box -f Containerfile .
