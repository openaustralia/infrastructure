**Table of Contents**

# Automated setup and configuration for most of OpenAustralia Foundation's servers

<!-- vscode-markdown-toc -->

- [Automated setup and configuration for most of OpenAustralia Foundation's servers](#automated-setup-and-configuration-for-most-of-openaustralia-foundations-servers)
  - [Other Documents](#otherdocuments)
  - [The tools](#thetools)
  - [Provisioning](#provisioning)
    - [Provisioning local development servers using Vagrant](#provisioning-local-development-servers-using-vagrant)
    - [Provisioning production servers](#provisioning-production-servers)
    - [Forcibly renewing LetsEncrypt certificates on production servers](#forcibly-renewing-letsencrypt-certificates-on-production-servers)
      - [Filtering hosts and/or tasks performed](#filtering-hosts-andor-tasks-performed)
  - [Accessing servers](#accessingservers)
  - [Deploying](#deploying)
  - [Backups](#backups)
  - [Git Tags](#gittags)
  - [Mail Catching](#mail-catching)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='otherdocuments'></a>Other Documents

History and background context (including the changelog-style "Updates" entries) has moved to
[docs/history.md](docs/history.md).

See [AGENTS.md](AGENTS.md) for AI Agent guidelines.

See [docs/DECISIONS.md](docs/DECISIONS.md) for Cross-cutting engineering decisions and directives that aren't tied to
one file or area.

One-time setup instructions (prerequisites, credentials, the Ansible Vault password, and generating dev SSL
certificates) have moved to [INSTALL.md](INSTALL.md).

## <a name='thetools'></a>The tools

To get a completely working server and service up and running requires a number
of different tools. We use different tools for different things.

- Terraform: To spin up servers, manage DNS and IP addresses, and setting up any
  related AWS infrastructure
- Ansible: To configure individual servers - install packages, create directory
  structures, install SSL certificates, configure cron jobs, create databases,
  etc..
- Vagrant: For local development of the Ansible setups for the servers. The
  vagrant boxes are not designed for doing application development. For that
  go to the individual application repositories.
- Capistrano: For application deployment. This is what installs the actual
  web application and updates the database schema.

Each application has its own repository and this is where application deployment
is done from. This repository just contains the Terraform and Ansible configuration
for the servers.

A little note on terminology:

- "assembling" (suggested, for consistency - not yet in wide use) - using Terraform to create/update the
  infrastructure a server needs (EC2 instances, RDS databases, DNS, load balancers, etc.), before Ansible ever
  touches the server.
- "provisioning" - we use this to mean configuring the server with Ansible.
- "deployment" - we use to mean installing or updating the web application with Capistrano.

## <a name='Templates'></a>Templates

Every file rendered through Ansible's `template:` module **must** use a `.j2`
extension (for example `general.yml.j2`, `nginx.conf.j2`, `sidekiq.service.j2`).
This keeps Jinja2 templates visually distinct from finished config files and keeps
them out of the YAML/JSON linters, which would otherwise try to parse the
un-rendered template.

- Give the template file its content extension followed by `.j2`
  (`database.yml` becomes `database.yml.j2`). The `src:` in the task must match; the
  `dest:` keeps the real filename with no `.j2`. When `dest:` is a directory, name the
  file explicitly (`dest: /srv/www/production/shared/general.yml`) - Ansible does not
  strip `.j2` for you.
- If a file has no Jinja2 (`{{ ... }}` / `{% ... %}`) it is not a template. Put it in
  the role's `files/` directory and use `copy:` instead.

`make template-check` enforces this - it fails if any file under an internal
role's `templates/` directory does not end in `.j2`, and it runs in CI.
Third-party roles under `roles/external/` are not checked, as we don't control
their layout.

## <a name='Updates'></a>Updates

### <a name=''></a>2025-05-27

_Umm. 7 years later, plus one day. That's weird._

#### <a name='SupportedPlatforms'></a>Supported Platforms

In the past, the tools in this repo were well supported across most common Linux platforms (including WSL), and OS X. However, newer versions of OSX only run on ARM chips, and older versions of OS X are increasingly unsupported by tools such as VirtualBox and Docker.

As of today, the only platform that we know works is debian-based Linux systems. Other linuxes probably work, including WSL; and there are probably two releases of MacOS which still run on the last generations of Intel Macs which might work.

We'd like to expand this in future, when we have time

#### <a name='RightToKnowDevplatform'></a>RightToKnow Dev platform

We've moved RTK on to upstream Alavateli, so the instructions below for a dev environment are out of date. Please refer to [openaustralia/righttoknow](https://github.com/openaustralia/righttoknow?tab=readme-ov-file#development)'s README for instructions.

#### <a name='PlanningAlertsProduction'></a>PlanningAlerts Production

We now have two production servers. Every day deployment is still run by Capistrano. For major upgrades (e.g., updating the Ruby version), we have the option of a blue/green deployment driven by Terraform, allowing us to update without downtime.

### <a name='-1'></a>2018-05-26

This repo is being used to setup and configure servers on EC2 for:

- planningalerts.org.au:
  - planningalerts.org.au
  - test.planningalerts.org.au
  - A cron job that uploads planningalerts data for a commercial client
- theyvoteforyou.org.au:
  - theyvoteforyou.org.au
  - test.theyvoteforyou.org.au
- openaustralia.org.au:
  - openaustralia.org.au
  - test.openaustralia.org.au
  - data.openaustralia.org.au
  - software.openaustralia.org.au
- righttoknow.org.au:
  - righttoknow.org.au
  - test.righttoknow.org.au
- openaustraliafoundation.org.au:
  - openaustraliafoundation.org.au
  - CiviCRM
- opengovernment.org.au (decommissioned)

On Linode running as separate VMs with automated server configuration:

- cuttlefish.oaf.org.au - automated server configuration using Ansible at
  <https://github.com/mlandauer/cuttlefish/tree/master/provisioning>
  (being replaced by postal.oaf.org.au - see
  [#365](https://github.com/openaustralia/infrastructure/issues/365))
- morph.io - automated server configuration using Ansible at
  <https://github.com/openaustralia/morph/tree/master/provisioning>
- postal.oaf.org.au - [Postal](https://github.com/postalserver/postal) mail
  server replacing cuttlefish, assembled and provisioned from this repository -
  see [docs/POSTAL.md](docs/POSTAL.md)

If it makes sense we might move cuttlefish and morph.io to AWS as well.

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
configuration. The Cloudflare and Linode provider tokens are the exception: they're shared service tokens kept in the \*
\*DevOps\*\* 1Password vault and rendered by `make tf-secrets`. Install and configure the ones you need:

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

## <a name='Provisioning'></a>Provisioning

### <a name='ProvisioninglocaldevelopmentserversusingVagrant'></a>Provisioning local development servers using Vagrant

In development, you set up and provision a server using Vagrant. You probably only want to run
one main server and the mysql server, so you can bring it up with:

    vagrant up mysql.test web.planningalerts.test

If it's already up, you can re-run Ansible provisioning with:

    vagrant provision oaf

Or combine with:

    vagrant up --provision staging.righttoknow.test

### <a name='Provisioningproductionservers'></a>Provisioning production servers

First use the `make check-<site>` commands to check what will change is as you expect.
If necessary, skip specific tags to skip over areas that fail on check, eg:

    SKIP_TAGS=mount_data,xapian make check-openaustralia

Provision all running servers (production and staging) with:

    make all

This will create a Python virtualenv in `venv`; install ansible inside it; and install required roles from ansible-galaxy inside `roles/external`

If you just want to provision a single server:

    make apply-planningalerts

or where there are multiple servers, specify which one you want to provision:

     STAGE=old make apply-openaustralia

To provision all stages, just specify `STAGE=all`

The repo will be tagged `wip-TARGET_UTC-TIME[_STAGE][-TAGS][-not-SKIP_TAGS]` before the command starts,
which will be replaced with `TARGET_UTC-TIME[_STAGE][-TAGS][-not-SKIP_TAGS]` upon success.
With tags pushed to origin, so everyone can see what was changed on servers.

The postal mail server needs Terraform and some one-off manual steps as well as Ansible -
see [docs/POSTAL.md](docs/POSTAL.md).

### <a name='ForciblyrenewingLetsEncryptcertificatesonproductionservers'></a>Forcibly renewing LetsEncrypt certificates on production servers

When first provisioning a server, Ansible will check to see if
`certbot_webroot` is set (this is used on RightToKnow). If not, it
looks for `certbot_webserver`. If that's not set either, Ansible
assumes that the web server is Apache.

Ansible then installs and configures Certbot, and uses it to create
certificates for all domains listed in `certbot_certs`.

Code for this is in the [oaf.certbot role](https://github.com/openaustralia/infrastructure/blob/9d251b5e86623efaadcd1ee39dc429cfb6f95607/roles/internal/oaf.certbot/tasks/main.yml#L16).

Sample config at [RTK](https://github.com/openaustralia/infrastructure/blob/9d251b5e86623efaadcd1ee39dc429cfb6f95607/roles/internal/righttoknow/tasks/certificates.yml#L47).

After this, Certbot runs from cron (or systemd) and renews
certificates automatically with no downtime.

In the unlikely event that you need to forcibly renew certificates:

    make letsencrypt

will use Ansible to forcibly renew every already-registered
certificate, using the same `cerbot_webserver` and `certbot_webroot`
config.

If you want to forcibly renew just one service, instructions are in
the top of `update-ssl-certs.yaml`.

#### Filtering hosts and/or tasks performed

You can also set:

- STAGE: to a group suffix eg `STAGE=staging make apply-righttoknow` would apply changes only to `righttoknow_staging`
  group in `inventory/ec2-hosts` which only contains `staging.openaustralia.org.au`
- `ANSIBLE_TAGS` - limits to tasks / roles that have one of the comma-separated roles
- `ANSIBLE_SKIP_TAGS` - skips tasks / roles that have one of the comma-separated roles
- `ANSIBLE_VERBOSE` - set to one to four 'v's eg `ANSIBLE_VERBOSE=vvv make apply-openaustralia` will show a lot of diagnostic information from ansible
- `ANSIBLE_START_TASK` - set to part of the task description to have ansible skip to that task, which allows you to quickly debug after a failure

## <a name='Accessingservers'></a>Accessing servers

Direct SSH access is being phased out in favour of AWS SSM Session Manager. For any instance with a
`PublicHostname` tag set:

    make ssh-config

prints an OpenSSH `~/.ssh/config` block - one `Host` entry per instance, aliased by its public hostname, `Name`
tag, and instance ID, proxying through SSM rather than a direct network connection. Paste the output into your
own `~/.ssh/config` yourself; it's not written there automatically. Re-run and re-paste after any instance
replacement (blue/green cutover, AMI refresh, etc.), since the resolved instance IDs go stale.

For a quick fleet-wide health check:

    make server-status

runs `uptime`, `free -m`, `df` (space and inodes), and a failed-systemd-units check against every host in
inventory. Scope it to one host or group with `HOST=<host-or-group>`, e.g. `make server-status
HOST=planningalerts`.

## <a name='Deploying'></a>Deploying

Deployment is service-specific - see:

- Right To Know: see [docs/righttoknow.md](docs/righttoknow.md)
- PlanningAlerts: see [docs/planningalerts.md](docs/planningalerts.md)
- They Vote For You (including "Running tests locally"): see [docs/theyvoteforyou.md](docs/theyvoteforyou.md)
- OpenAustralia: see [docs/openaustralia.md](docs/openaustralia.md)

## <a name='Backups'></a>Backups

Data directories of servers are backed up to S3 using Duply.

Using the `data_directory` profile as an example, to run a backup manually you'd log in as root and run `duply data_directory backup`.

To restore the latest backup to `/mnt/restore` you'd run `duply data_directory restore /mnt/restore`.

## <a name='gittags'></a>Git Tags

The make `apply-*` and `tf-apply*` targets create a git tag before and after the command to actually change the
infrastructure is called so it is clear what has and hasn't been fully actioned. A `wip-*` tag that sticks around
indicates a failed provisioning command.

The `bin/tag-provisioning` command is called to tag the latest commit. Specifically it:

1. creates a git tag with `wip-` prefix to indicate that changes to infrastructure had been started and pushes it to GitHub;
2. runs the requested command;
3. creates the git tag without the `wip-` prefix and pushes it to GitHub;
4. removes the wip git tag locally and on GitHub, so it is clear the command succeeded.

Terraform tags (from `make tf-apply`) will start with `[wip-]terraform` and then have the timestamp, eg
`terraform_20260717125154`.

Ansible tags (from `make apply-*`) will start with the service being targetted, and then have the timestamp, followed
by the `STAGE`, `TAGS`, and `SKIP_TAGS` values, if set.

## <a name='MailCatching'></a>Mail Catching

Mail catching configuration has moved to [docs/openaustralia.md](docs/openaustralia.md).
