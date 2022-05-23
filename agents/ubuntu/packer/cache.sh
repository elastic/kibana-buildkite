#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

AGENT_USER="buildkite-agent"

# Bootstrap cache
su - "$AGENT_USER" <<'EOF'
set -e
git --git-dir /var/lib/gitmirrors/https---github-com-elastic-kibana-git fetch origin main
git clone /var/lib/gitmirrors/https---github-com-elastic-kibana-git /var/lib/buildkite-agent/.kibana
cd /var/lib/buildkite-agent/.kibana
git checkout main
HOME=/var/lib/buildkite-agent bash .buildkite/scripts/packer_cache.sh

cd -
EOF
