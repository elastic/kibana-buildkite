#!/bin/bash

set -euo pipefail

retry() {
  local retries=$1; shift
  local delay=$1; shift
  local attempts=1

  until "$@"; do
    retry_exit_status=$?
    echo "Exited with $retry_exit_status" >&2
    if (( retries == "0" )); then
      return $retry_exit_status
    elif (( attempts == retries )); then
      echo "Failed $attempts retries" >&2
      return $retry_exit_status
    else
      echo "Retrying $((retries - attempts)) more times..." >&2
      attempts=$((attempts + 1))
      sleep "$delay"
    fi
  done
}

export VAULT_ADDR=https://secrets.elastic.co:8200

VAULT_ROLE_ID="$(cat ~/.vault-role-id)"
VAULT_SECRET_ID="$(cat ~/.vault-secret-id)"

VAULT_TOKEN=$(retry 5 30 vault write -field=token auth/approle/login role_id="$VAULT_ROLE_ID" secret_id="$VAULT_SECRET_ID")
retry 5 30 vault login -no-print "$VAULT_TOKEN"

# # Creates an in-memory credential cache for git, and populates it with the kibanamachine token for 15 minutes for https requests to github
# {
#   KIBANAMACHINE_TOKEN="$(retry 5 15 vault read -field=github_token secret/kibana-issues/dev/kibanamachine)"
#   git config --global credential.helper store
#   echo "protocol=https
# host=github.com
# username=token
# password=$KIBANAMACHINE_TOKEN" | git credential-store store
# }

export DOCKER_BUILDKIT=1
