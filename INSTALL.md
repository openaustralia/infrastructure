**Table of Contents**

# Installing and getting started

<!-- vscode-markdown-toc -->
- [Installing and getting started](#installing-and-getting-started)
  - [Requirements](#requirements)
    - [Prerequisites](#prerequisites)
      - [CLI tools for credentials](#cli-tools-for-credentials)
    - [Environment setup](#environment-setup)
    - [Accepting SSH host keys for the fleet](#accepting-ssh-host-keys-for-the-fleet)
    - [Add the Ansible Vault password](#add-the-ansible-vault-password)
      - [Recommended: 1Password](#recommended-1password)
      - [Rotating a vault passphrase](#rotating-a-vault-passphrase)
      - [Memory and CPU Usage](#memory-and-cpu-usage)
      - [Access to everything except right to know](#access-to-everything-except-right-to-know)
  - [Generating SSL certificates for development](#generating-ssl-certificates-for-development)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='Requirements'></a>Requirements

### <a name='Prerequisites'></a>Prerequisites

- For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/) and a supported provider - our
  instructions assume [VirtualBox](https://developer.hashicorp.com/vagrant/docs/providers/virtualbox).
- In order to run Ansible, you'll need Python < 3.12 installed
    - 3.12 dropped some deprecated language features which
      cause [Ansible 2.9 and 2.10 to no longer work](https://github.com/ansible/ansible/issues/81946).
    - Secrets: Ansible passphrases are read from the OAF 1Password account.
      See [Add the Ansible Vault password](#add-the-ansible-vault-password) below.
- In order to run Capistrano, you'll need a version of Ruby installed; even better, install [rbenv](https://rbenv.org/)
  so that you're able to manage multiple versions of Ruby.
- For deploying code onto dev/test/prod machines, you'll need [capistrano](http://capistranorb.com/)
- For a few things, including major PlanningAlerts deployments, you'll
  need [Terraform](https://developer.hashicorp.com/terraform/install). Terraform reads its AWS and Google credentials
  from your own CLI tooling — see [CLI tools for credentials](#cli-tools-for-credentials) below. The shared secrets —
  the RDS admin password and the Cloudflare and Linode API tokens — are rendered into `terraform/secrets.auto.tfvars`
  from 1Password by `make tf-secrets`.
- For AWS's SSM Session Manager access (replacing SSH), you'll need
  the [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html).
  Run `make aws-check` to confirm it and the AWS CLI are both installed.
- `jq` must be installed for `terraform/prepkey.sh`
- The key found by the `terraform/prepkey.sh` script should be
    - registered as an ssh key in your GitHub account,
    - used by ssh for the hostnames in `inventory/ec2-hosts`
        - add entries to your `~/.ssh/config` if not using the default `~/.ssh/id_{ed25519,rsa}.pub` files
- The `terraform/prepkey.sh` looks for public keys from
    - First GitHub key if `$GITHUB_USER` is set
    - `${SSH_PUBLIC_KEY_FILE:-}` if set
    - `~/.ssh/id_{ed25519,rsa}*oaf*.pub`
    - `~/.ssh/id_{ed25519,rsa}*OAF*.pub`
    - `~/.ssh/id_{ed25519,rsa}*open*au*.pub`
    - `~/.ssh/id_{ed25519,rsa}*OPEN*AU*.pub`
    - `~/.ssh/id_{ed25519,rsa}.pub`
- Note the ansible `internal/deploy-user` role replaces the authorized list from the keys registered for `github_users`
  when run by anyone so mismatches will cause connection problems!
- See the following section for cli tools prerequisites.

#### <a name='CLItoolsforcredentials'></a>CLI tools for credentials

Operator credentials (AWS, Google) aren't stored in this repo or 1Password — each tool reads from your own CLI
configuration. The Cloudflare and Linode provider tokens are the exception: they're shared service tokens kept in
the **DevOps** 1Password vault and rendered by `make tf-secrets`. Install and configure the ones you need:

- **1Password CLI (`op`)** — required to read the shared Ansible Vault passphrases and the RDS admin password.
    - Install: `brew install --cask 1password-cli` on macOS, or
      the [official package](https://developer.1password.com/docs/cli/get-started) on Linux.
    - The CLI normally inherits a session from the 1Password desktop app. If you're running headless, sign in once with
      `op signin --account oaforgau`.
      - Note: enable App > Developer > Settings > "Integrate with 1Password CLI", otherwise you need to run `eval $(op signin --account oaforgau)` instead.
    - Ask an existing admin to add you to the **DevOps** vault.
- **AWS CLI (`aws`)** — required for Terraform's AWS provider and for reading S3-backed Terraform state.
  Install using the official
  [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  instructions.
    - We recommend you sign in with [`aws login --profile oaf`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html)
      which uses a browser-based authentication flow (supporting MFA) to provide temporary credentials.
    - Terraform doesn't understand its `login_session` credentials directly yet, so bridge them by editing
      `~/.aws/config`:
      ```ini
      [profile oaf]
      login_session = arn:aws:iam::924104513718:user/<your-user>
      region = ap-southeast-2

      [profile oaf-legacy]
      # Bridges `aws login` to tools that don't understand `login_session` yet (e.g. Terraform, Ansible).
      credential_process = aws configure export-credentials --profile oaf --format process
      region = ap-southeast-2
      ```
      Then `aws login --profile oaf` to authenticate. `terraform` (via each provider's `profile = "oaf-legacy"`) and
      the `aws_ec2` Ansible inventory (via `aws_profile: oaf-legacy` in `inventory/aws_ec2.yml`) pick this up
      explicitly. `cap` has no AWS touchpoint yet, and there's nowhere else with a per-tool profile setting, so for
      that — and any ad hoc `aws`/`cap` commands — set `export AWS_PROFILE=oaf-legacy` in your `.envrc`. If you'd
      rather everything default to `oaf-legacy` without setting `AWS_PROFILE`, you can instead duplicate the
      `[profile oaf-legacy]` block above as `[default]` in `~/.aws/config`.
    - The `oaf` profile's `login_session` ARN has the OAF account ID (`924104513718`) baked in, so if you ever sign
      in to a different AWS account, `aws login --profile oaf` will notice the mismatch and ask you to confirm before
      overwriting it — a safety net against authenticating against the wrong account.
  - We no longer support (because we use oaf-legacy profile):
    - `aws sso login` as it has a more complicated setup,
    - `aws configure`, or AWS vars in dotenv's `.envrc` file as these long-lived credentials do not use MFA and are
      stored on the local file system in plain text.
- **Google Cloud SDK (`gcloud`)** — required for Terraform's Google provider. After installation, run
  `gcloud auth application-default login`.
- **Cloudflare and Linode API tokens** — no per-operator setup. These are shared service tokens stored in the **DevOps**
  1Password vault (item _Terraform DB Passwords_); `make tf-secrets` renders them into `terraform/secrets.auto.tfvars`
  and the providers read them from there. You no longer need to export `CLOUDFLARE_API_TOKEN` or `LINODE_TOKEN`.

Run `make tf-env-check` to verify each of these is reachable from your shell before running Terraform.

Use `make setup` to install packages on Ubuntu for development.

Use `mise install` to install the ruby and python versions required - see [mise](https://mise.jdx.dev/) for further details.

Run `make requirements` to install the requirements for python and ansible.


**Ansible**

- In order to run the Ansible playbooks, you'll need Python 3.11 installed (as per `.python-version`)
  - Note v3.12 dropped some deprecated language features which cause [Ansible 2.9 and 2.10 to no longer work](https://github.com/ansible/ansible/issues/81946).

**Secrets**

- Ansible reads each vault passphrase from the OAF 1Password account via [bin/ansible-vault-client](bin/ansible-vault-client). See [Add the Ansible Vault password](#add-the-ansible-vault-password) below.

**Capistrano (in project repos)**

- In order to run Capistrano, you'll need a version of Ruby installed;
  - Consider installing [mise](https://mise.jdx.dev/) so that you're able to install and swap between multiple versions of Ruby, python, and php.
- For deploying code onto dev/test/prod machines, you'll need to install [capistrano](http://capistranorb.com/) using `bundle install`

**Terraform**

For a few things, including major PlanningAlerts deployments, you'll need [Terraform](https://developer.hashicorp.com/terraform/install)

- Install [the gCloud CLI](https://cloud.google.com/sdk/docs/install) and configure with authentication credentials,
  which requires some extra secrets than ansible needs:
- Run `make tf-secrets` to render `terraform/secrets.auto.tfvars` from 1Password — this provides the `rds_admin_password`, `cloudflare_api_token`, and `linode_api_token` (see [CLI tools for credentials](#cli-tools-for-credentials) above).
- **AWS** - You need an account with the same permissions as the `ansible` user (from ansible vault) or better
  - to access the S3 bucket we use to store Terraform's permanent state.
- The `cloudflare_api_token` needs at least `Zone / Zone / Read` perms for planning, and `Zone / Zone / Write` for updating
- The `linode_api_token` needs at least read access for planning and full access for updating
- Terraform requires that you have [the gCloud CLI](https://cloud.google.com/sdk/docs/install) set up and configured with authentication credentials it can use
  - run `gcloud auth application-default login`
- See the notes on `terraform/prepkey.sh` in the prerequisites section for how new instances are initially configured with (only) your ssh key.
  - terraform will replace aws_key_pair.deployer to update the value if someone else applied the last changes,
    this is to be expected and is not a concern.
- You should run Ansible on all new EC2 instances so the `internal/deploy-user` role can instead grant access to the ssh keys of everyone
  listed in `github_users` (defined in `group_vars/all.yml`).
- We host DNS on Cloudflare.
  - An API key to manage these zones is one of the secrets you'll need to provide.
  - To get access to the configs in the [Cloudflare dashboard](https://dash.cloudflare.com), you'll need access to the organisation - see Ben or James for details

### <a name='Environmentsetup'></a>Environment setup

There's a very handy `Makefile` included which will:

- install Vagrant plugins
- Create a python virtual environment
- Install `ansible-galaxy` roles and collections

Simply run

```
make requirements vagrant
```

### <a name='AcceptingSSHhostkeysforthefleet'></a>Accepting SSH host keys for the fleet

The first time you connect to any server, SSH asks you to confirm its host key. Running an Ansible command
against the whole fleet at once triggers that prompt for several hosts in parallel, and your answers can end
up going to the wrong prompt - limit it to one host at a time to get through them cleanly:

```
make requirements
.venv/bin/ansible all -i ./inventory -m command -a uptime --forks 1
```

Only needed once per host - once a key's accepted it's cached in `~/.ssh/known_hosts`, and later commands
(e.g. `make server-status`) go back to running in parallel without prompting.

### <a name='AddtheAnsibleVaultpassword'></a>Add the Ansible Vault password

Each `ansible-vault` encrypted value in this repo is tagged with one of four vault IDs (`default`, `all`, `ec2`, `rtk`). Ansible reads the passphrase for each ID by invoking [bin/ansible-vault-client](bin/ansible-vault-client), which fetches it from the OAF 1Password account.

#### Recommended: 1Password

1. Install the 1Password CLI per [CLI tools for credentials](#cli-tools-for-credentials) above and sign in to the OAF account.
2. Ask an existing admin to add you to the **DevOps** vault. The passphrase items already exist there — including the `rtk` one, which lives in DevOps for now rather than the separate **RTK Devops** vault.
3. `make requirements` will detect that you're signed in and run the rest of the setup; no further action needed.

Verify with:

```bash
bin/ansible-vault-client --vault-id ec2 | wc -c   # should print the length of the ec2 passphrase
```

#### <a name='Rotatingavaultpassphrase'></a>Rotating a vault passphrase

Run:

```bash
bin/rotate-vault-passphrase <vault-id>           # one of: default, all, ec2, rtk
bin/rotate-vault-passphrase <vault-id> --dry-run # check what would change without writing
```

The script reads the current passphrase via the dispatcher, generates a new one, walks `group_vars/` and `host_vars/` re-encrypting every `!vault` block tagged with that ID, and writes the new passphrase to 1Password. Commit the resulting diff (only `!vault` blocks tagged with that ID should change) and notify other operators.

#### Memory and CPU Usage

Vagrant will allocate 2 GB of RAM and 2 CPU cores per VM by default, which can be overridden.
When tested with provisioning openaustralia from scratch (YMMV) compared to default settings:
- `VAGRANT_MEMORY=4096` was 9% faster if you have enough host memory (2 x memory)
- `VAGRANT_CPUS=1 VAGRANT_MEMORY=3072` for running many VMs (12% slower with 1/2 cores and 1.5 x memory)
- `VAGRANT_CPUS=1` minimum (20% slower with 1/2 cores)

FYI These production systems have more than 2 CPUs and/or 2 GiB memory:

- planningalerts - 2x t3.medium, 4 GiB RAM
- righttoknow - t3.large 8 GiB memory, (staging t3.medium, 4 GiB RAM)
- morph - linode 32 GB, 8 cpu, 2 GB swap
- theyvoteforyou - t3.xlarge - 4 vCPUs, 16 GiB memory

#### Access to everything except right to know

All four passphrases currently live in the same **DevOps** 1Password vault, so DevOps membership grants read access to `rtk` too — there's no separate vault-level restriction today. If that changes (e.g. `rtk` moves to its own vault, or you're given access to only some of the four items), use `.envrc` (and the `direnv` package) to set the following whenever you cd to this dir, listing only the vault ids you can read:


```bash
export ANSIBLE_VAULT_IDENTITY_LIST="default@bin/ansible-vault-client,ec2@bin/ansible-vault-client,all@bin/ansible-vault-client"
```


This will allow you to work on everything except right to know.

## <a name='GeneratingSSLcertificatesfordevelopment'></a>Generating SSL certificates for development

See certificates/README.md for more information. This also generates a certificate for morph local development if present.
