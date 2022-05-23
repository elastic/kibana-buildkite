#!/usr/bin/env bash

set -euo pipefail

cd agents/ubuntu

echo --- Building packer builder docker image
docker build --progress plain -t packer-builder .

echo --- Building agent image
docker run -it --rm --init -e "VAULT_ADDR" --volume "$HOME/.vault-token:/root/.vault-token" --volume "$(pwd)":/app --workdir /app packer-builder ./packer_build_cache.sh
