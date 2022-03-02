#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

# Install docker credential helpers for GCR and GAR
sudo -u buildkite-agent gcloud auth configure-docker us-central1-docker.pkg.dev,gcr.io,us.gcr.io --quiet

# Setup Buildkite agent configuration
{
  agentConfig="$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/buildkite-agent-config -qf -H "Metadata-Flavor: Google" || true)"

  BUILDKITE_TOKEN="$(gcloud secrets versions access latest --secret=kibana-buildkite-agent-token)"
  echo "${agentConfig}" >> /etc/buildkite-agent/buildkite-agent.cfg
  echo "token=$BUILDKITE_TOKEN" >> /etc/buildkite-agent/buildkite-agent.cfg
}

# Setup local SSD support
{
  if [[ -e /dev/nvme0n1 ]]; then
    echo "Setting up Local SSD..."
    mkfs.ext4 -F /dev/nvme0n1
    mkdir -p /opt/local-ssd
    mount -o discard,defaults,nobarrier,noatime /dev/nvme0n1 /opt/local-ssd
    chmod a+w /opt/local-ssd
    mkdir /opt/local-ssd/buildkite
    chown buildkite-agent:buildkite-agent /opt/local-ssd/buildkite
    echo 'build-path="/opt/local-ssd/buildkite/builds"' >> /etc/buildkite-agent/buildkite-agent.cfg
  fi
}

# Setup Elastic Agent
{
  ELASTIC_AGENT_HOST="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-host)"
  ELASTIC_AGENT_USERNAME="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-username)"
  ELASTIC_AGENT_PASSWORD="$(gcloud secrets versions access latest --secret=kibana-buildkite-elastic-agent-password)"

  cd /opt/elastic-agent-install
  sed -i "s/ELASTIC_AGENT_HOST/$(printf '%s\n' "$ELASTIC_AGENT_HOST" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  sed -i "s/ELASTIC_AGENT_USERNAME/$(printf '%s\n' "$ELASTIC_AGENT_USERNAME" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  sed -i "s/ELASTIC_AGENT_PASSWORD/$(printf '%s\n' "$ELASTIC_AGENT_PASSWORD" | sed -e 's/[\/&]/\\&/g')/" elastic-agent.yml
  ./elastic-agent install -f
}

systemctl enable buildkite-agent
systemctl start buildkite-agent

exit 0
