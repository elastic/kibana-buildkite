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
4. Make sure your SSH key is added to infra's repository, see [example PR](https://github.com/elastic/infra/pull/12055/files)
5. Clone https://github.com/elastic/infra somewhere
6. Run `./setup.sh <path to your local infra repo>` to symlink to necessary files
   1. This step is necessary because several files must be in your working directory in order to use infra's ssh_config

## Run

One of the ansible plugins currently requires this: `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`

`ansible-playbook -u <your_ssh_username> playbook.yml`

# New Instances

1. Add the new instance to `hosts`
2. Provision the instance `ansible-playbook -u <your_username> -l <hostname_from_hosts_file> provision.yml`
   - This will fully set up the instance, and connect it to Buildkite
