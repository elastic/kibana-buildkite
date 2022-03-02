#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

AGENT_USER="buildkite-agent"
AGENT_HOME="/var/lib/buildkite-agent"

### Patch the filesystem options to increase I/O performance
{
  tune2fs -o ^acl,journal_data_writeback,nobarrier /dev/sda1
  cat > /etc/fstab <<'EOF'
LABEL=cloudimg-rootfs  /               ext4    defaults,noatime,commit=300,journal_async_commit        0 0
LABEL=UEFI               /boot/efi     vfat    defaults,noatime        0 0
EOF
}

# These should be in /etc/sysctl.conf !!!
# They should be tested more before enabling them in the correct place
# cat >> /etc/security/limits.conf <<'EOF'
# # From Jenkins workers
# fs.file-max=500000
# vm.max_map_count=262144
# kernel.pid_max=4194303
# fs.inotify.max_user_watches=8192

# # From bazel
# kernel.sched_min_granularity_ns=10000000
# kernel.sched_wakeup_granularity_ns=15000000
# vm.dirty_ratio=40
# kernel.sched_migration_cost_ns=5000000
# kernel.sched_autogroup_enabled=0
# EOF

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
git-clone-mirror-flags="-v --bare"
git-fetch-flags="-v"
timestamp-lines=true
EOF

mv /tmp/bk-hooks/* /etc/buildkite-agent/hooks/
chown -R "$AGENT_USER:$AGENT_USER" /etc/buildkite-agent/hooks
chmod +x /etc/buildkite-agent/hooks/*

gcloud auth configure-docker --quiet

# Setup git mirrors
{
  cd /var/lib/gitmirrors
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

apt-get clean
rm -rf /var/lib/apt/lists/*

# Bootstrap cache
su - buildkite-agent <<'EOF'
set -e
git clone /var/lib/gitmirrors/https---github-com-elastic-kibana-git /var/lib/buildkite-agent/.kibana
cd /var/lib/buildkite-agent/.kibana
git checkout main
HOME=/var/lib/buildkite-agent bash .buildkite/scripts/packer_cache.sh

cd -
EOF

sync

sleep 3
