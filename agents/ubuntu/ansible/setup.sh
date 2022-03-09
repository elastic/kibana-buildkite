#!/bin/bash

set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <path to your local infra repo clone>"
    exit 1
fi

rm -f .known_hosts
rm -f ssh_config
rm -f vssh

ln -s "$1/ansible/.known_hosts" .known_hosts
ln -s "$1/ansible/ssh_config" ssh_config
ln -s "$1/ansible/vssh" vssh
