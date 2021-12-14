# Getting Started

## Requirements

- python 3.x
- vault access

Do not install ansible via homebrew.

### (Optional) Python management via pyenv

```
curl https://pyenv.run | bash
pyenv install
python --version
```

## Setup

1. `pip install -r requirements.txt`
2. `ansible-galaxy install -r requirements.yml`
3. Make sure you are authenticated with Vault

## Run

One of the ansible plugins currently requires this: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`

`ansible-playbook provision.yml`

# New Instances

1. [Optional] Set up your SSH key with `ssh-copy-id administrator@IP_ADDRESS_OR_HOSTNAME`
2. Change the default password for instance with `passwd`
3. Add the new instance password to Vault `secret/kibana-issues/dev/macstadium-admin-credentials`
4. Add the new instance to `hosts`
5. Run `ansible-playbook -e "host=<hostname_from_hosts>" bootstrap.yml`
   - Be sure not to run against all of the hosts, as it will reboot them
6. Provision the instance `ansible-playbook -l <hostname_from_hosts_file> provision.yml`
   - This will fully set up the instance, and connect it to Buildkite
