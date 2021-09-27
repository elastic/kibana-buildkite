#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

AGENT_USER="buildkite-agent"
AGENT_HOME="/var/lib/buildkite-agent"

sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198

rm -rf /var/lib/apt/lists/*

apt-get update --yes
apt-get install --yes \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  buildkite-agent

### Get rid of Ubuntu's snapd stuff and install the Google Cloud SDK the traditional way.
{
  apt-get -y remove --purge snapd
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
      tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
      apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt-get -y update
  apt-get -y install google-cloud-sdk
}

### Disable automatic upgrades, as they can interfere with our startup scripts.
{
  cat > /etc/apt/apt.conf.d/10periodic <<'EOF'
APT::Periodic::Enable "0";
EOF
}

### Increase file descriptor limits
{
  cat >> /etc/security/limits.conf <<'EOF'
*                soft    nofile          100000
*                hard    nofile          100000
EOF
}

### Patch the filesystem options to increase I/O performance
{
  tune2fs -o ^acl,journal_data_writeback,nobarrier /dev/sda1
  cat > /etc/fstab <<'EOF'
LABEL=cloudimg-rootfs  /               ext4    defaults,noatime,commit=300,journal_async_commit        0 0
LABEL=UEFI               /boot/efi     vfat    defaults,noatime        0 0
EOF
}

# TODO
### Install node + yarn
{
  curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  apt-get install -y nodejs

  npm install -g yarn
}

### Install GitHub cli (gh)
{
  apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
  apt-add-repository https://cli.github.com/packages
  apt update
  apt install gh
}

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

### Setup docker config and userns remap https://docs.docker.com/engine/security/userns-remap/
{
  uid=$(id -u "$AGENT_USER")
  gid=$(id -g "$AGENT_USER")
  lastuid=$((uid + 65536))
  lastgid=$((gid + 65536))

  usermod --add-subuids "$uid"-"$lastuid" "$AGENT_USER"
  usermod --add-subgids "$gid"-"$lastgid" "$AGENT_USER"

  mkdir -p /etc/docker
  cat > /etc/docker/daemon.json <<EOF
{
  "userns-remap": "buildkite-agent:buildkite-agent"
}
EOF
}

apt-get update --yes

apt-get install --yes \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  git \
  jq \
  rsync \
  openjdk-11-jre-headless \
  unzip \
  build-essential \
  kubectl

apt-get -y install xvfb gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
      libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
      libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
      libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
      libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils

apt-get install -y google-chrome-stable firefox --no-install-recommends

LATEST_VAULT_RELEASE=$(curl -s https://api.github.com/repos/hashicorp/vault/tags | jq --raw-output .[0].name[1:]) \
  && curl -L https://releases.hashicorp.com/vault/${LATEST_VAULT_RELEASE}/vault_${LATEST_VAULT_RELEASE}_linux_amd64.zip -o vault.zip \
  && unzip vault.zip \
  && rm vault.zip \
  && chmod +x vault \
  && mv vault /usr/local/bin/vault

usermod -a -G docker "$AGENT_USER"

mkdir -p "$AGENT_HOME/.java"
cd "$AGENT_HOME/.java"

curl -O https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_linux-x64_bin.tar.gz
echo "91310200f072045dc6cef2c8c23e7e6387b37c46e9de49623ce0fa461a24623d openjdk-14.0.2_linux-x64_bin.tar.gz" | sha256sum --check
tar -xvf openjdk-14.0.2_linux-x64_bin.tar.gz
mv jdk-14.0.2 openjdk14

curl -O https://download.java.net/java/GA/jdk15.0.2/0d1cfde4252546c6931946de8db48ee2/7/GPL/openjdk-15.0.2_linux-x64_bin.tar.gz
echo "91ac6fc353b6bf39d995572b700e37a20e119a87034eeb939a6f24356fbcd207 openjdk-15.0.2_linux-x64_bin.tar.gz" | sha256sum --check
tar -xvf openjdk-15.0.2_linux-x64_bin.tar.gz
mv jdk-15.0.2 openjdk15

curl -O https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-16.0.1_linux-x64_bin.tar.gz
echo "b1198ffffb7d26a3fdedc0fa599f60a0d12aa60da1714b56c1defbce95d8b235 openjdk-16.0.1_linux-x64_bin.tar.gz" | sha256sum --check
tar -xvf openjdk-16.0.1_linux-x64_bin.tar.gz
mv jdk-16.0.1 openjdk16

chown -R "$AGENT_USER":"$AGENT_USER" .
cd -

cat > /etc/apt/apt.conf.d/10periodic <<'EOF'
APT::Periodic::Enable "0";
EOF

cat >> /etc/security/limits.conf <<'EOF'
*                soft    nofile          500000
*                hard    nofile          500000
*                soft    nproc          262144
*                hard    nproc          262144
EOF

cat >> /etc/security/limits.conf <<'EOF'
# From Jenkins workers
fs.file-max=500000
vm.max_map_count=262144
kernel.pid_max=4194303
fs.inotify.max_user_watches=8192

# From bazel
kernel.sched_min_granularity_ns=10000000
kernel.sched_wakeup_granularity_ns=15000000
vm.dirty_ratio=40
kernel.sched_migration_cost_ns=5000000
kernel.sched_autogroup_enabled=0
EOF

mkdir -p /etc/systemd/system/buildkite-agent.service.d
cat > /etc/systemd/system/buildkite-agent.service.d/10-agent-poweroff.conf <<'EOF'
[Service]
Restart=no
PermissionsStartOnly=true
ExecStopPost=/bin/systemctl poweroff
EOF

cat > /etc/systemd/system/buildkite-agent.service.d/10-disable-tasks-accounting.conf <<'EOF'
[Service]
# Disable tasks accounting
# This fixes the "cgroup: fork rejected by pids controller" error that some CI jobs triggered.
TasksAccounting=no
EOF

cat > /etc/buildkite-agent/buildkite-agent.cfg <<EOF
build-path="/var/lib/buildkite-agent/builds"
hooks-path="/etc/buildkite-agent/hooks"
plugins-path="/etc/buildkite-agent/plugins"
experiment="git-mirrors,output-redactor,ansi-timestamps,normalised-upload-paths,resolve-commit-after-checkout"
git-mirrors-path="/var/lib/gitmirrors"
#git-clone-flags="--dissociate"
#git-clone-mirror-flags="-v --bare"
git-clone-mirror-flags="-v --bare"
git-fetch-flags="-v"
#tags-from-gcp=true
#tags-from-gcp-labels=true
#tags-from-host=true
timestamp-lines=true
debug=true
EOF

mkdir -p /etc/buildkite-agent/hooks
mv /tmp/bk-hooks/* /etc/buildkite-agent/hooks/
chown -R "$AGENT_USER:$AGENT_USER" /etc/buildkite-agent/hooks
chmod +x /etc/buildkite-agent/hooks/*

gcloud auth configure-docker --quiet

# Setup git mirrors
{
  mkdir -p /var/lib/gitmirrors
  cd /var/lib/gitmirrors
  # docker pull gcr.io/elastic-kibana-184716/buildkite/ci/base:0afe7a0463e6a512646aaff775df5d3978dfb87b &
  git clone --mirror https://github.com/elastic/kibana.git https---github-com-elastic-kibana-git &
  git clone --mirror https://github.com/elastic/elasticsearch.git https---github-com-elastic-elasticsearch-git &
  wait

  chown -R "$AGENT_USER:$AGENT_USER" .
  chmod -R 0755 .

  cd -
}

mv /tmp/bk-startup.sh /opt/bk-startup.sh
chown root:root /opt/bk-startup.sh
chmod +x /opt/bk-startup.sh

systemctl disable buildkite-agent

# Setup Elastic Agent
# https://www.elastic.co/guide/en/fleet/current/run-elastic-agent-standalone.html
{
  cd /opt
  curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-7.12.0-linux-x86_64.tar.gz
  tar xzf elastic-agent-7.12.0-linux-x86_64.tar.gz
  mv elastic-agent-7.12.0-linux-x86_64 /opt/elastic-agent-install
  cp /tmp/elastic-agent.yml /opt/elastic-agent-install/
}

apt-get clean
rm -rf /var/lib/apt/lists/*

# Bootstrap cache
su - buildkite-agent <<'EOF'
git clone /var/lib/gitmirrors/https---github-com-elastic-kibana-git /var/lib/buildkite-agent/.kibana
cd /var/lib/buildkite-agent/.kibana
git checkout master
HOME=/var/lib/buildkite-agent bash .buildkite/scripts/packer_cache.sh

cd -
EOF

sync

sleep 3
