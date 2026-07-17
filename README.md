**Table of Contents**

# Automated setup and configuration for most of OpenAustralia Foundation's servers

<!-- vscode-markdown-toc -->
- [Automated setup and configuration for most of OpenAustralia Foundation's servers](#automated-setup-and-configuration-for-most-of-openaustralia-foundations-servers)
  - [A little history](#a-little-history)
  - [Approach](#approach)
  - [The tools](#the-tools)
  - [Updates](#updates)
    - [2025-05-27](#2025-05-27)
      - [Supported Platforms](#supported-platforms)
      - [RightToKnow Dev platform](#righttoknow-dev-platform)
      - [PlanningAlerts Production](#planningalerts-production)
    - [2018-05-26](#2018-05-26)
  - [Requirements](#requirements)
    - [Prerequisites](#prerequisites)
      - [CLI tools for credentials](#cli-tools-for-credentials)
    - [Environment setup](#environment-setup)
    - [Add the Ansible Vault password](#add-the-ansible-vault-password)
      - [Recommended: 1Password](#recommended-1password)
      - [Rotating a vault passphrase](#rotating-a-vault-passphrase)
      - [Memory and CPU Usage](#memory-and-cpu-usage)
      - [Access to everything except right to know](#access-to-everything-except-right-to-know)
  - [Generating SSL certificates for development](#generating-ssl-certificates-for-development)
  - [Provisioning](#provisioning)
    - [Provisioning local development servers using Vagrant](#provisioning-local-development-servers-using-vagrant)
    - [Provisioning production servers](#provisioning-production-servers)
    - [Forcibly renewing LetsEncrypt certificates on production servers](#forcibly-renewing-letsencrypt-certificates-on-production-servers)
      - [Filtering hosts and/or tasks performed](#filtering-hosts-andor-tasks-performed)
  - [Deploying](#deploying)
    - [Deploying Right To Know to your local development server](#deploying-right-to-know-to-your-local-development-server)
    - [Deploying PlanningAlerts](#deploying-planningalerts)
      - [Deploying PlanningAlerts to your local development server](#deploying-planningalerts-to-your-local-development-server)
      - [Deploying PlanningAlerts to production](#deploying-planningalerts-to-production)
    - [Running tests locally](#running-tests-locally)
    - [Deploying They Vote For You](#deploying-they-vote-for-you)
      - [Deploying They Vote For You to your local development server](#deploying-they-vote-for-you-to-your-local-development-server)
      - [Deploying They Vote For You to production](#deploying-they-vote-for-you-to-production)
    - [Deploying OpenAustralia](#deploying-openaustralia)
      - [Deploying OpenAustralia to your local development server](#deploying-openaustralia-to-your-local-development-server)
      - [Deploying OpenAustralia to production](#deploying-openaustralia-to-production)
  - [Backups](#backups)
  - [Git Tags](#gittags)
  - [Mail Catching](#mail-catching)
    - [`log_not_sendmail`](#log_not_sendmail)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='Alittlehistory'></a>A little history

When OpenAustralia Foundation started, it just ran openaustralia.org and a
blog site. Hosting was kindly sponsored by Andrew Snow from Octopus
computing who donated a virtual machine (VM) for us to use. That server
was called kedumba.

Over the years things grew organically. We created more projects all of which
we hosted from the single VM which we maintained by hand. Andrew kept making
the VM bigger and bigger with more and more disk space.

We ended up rebuilding the server twice over the course of 7 years in order to
upgrade the operating system and modernise some of the surrounding tools.
Each time it was a mammoth exercise.

Also, as more and more services were added to this one server the dependencies
became harder to manage.

So, in 2015, prior to the last major server rebuild we started working on an
automated server setup and configuration using Ansible that you see here
in this repository. We also took the
opportunity to split the different sites into different VM configurations.
However, unfortunately this work was abandoned due to a lack of time and
we ended up (from memory) rebuilding the server once again by hand as a giant
monolithic server.

In the years since then, things have become a little more complicated. We had
a second small VM running on Octopus which runs oaf.org.au, CiviCRM, and
elasticsearch. All of these had to run on a separate VM because they required
a more recent version of the operating system.

We also created two projects that we hosted outside of Octopus, on Linode:
cuttlefish.oaf.org.au and morph.io. morph.io needed docker which couldn't run
easily on kedumba. cuttlefish is a transactional email server that we
opened up for use by the civic tech community. We didn't want to risk cuttlefish
undermining the email reputation of kedumba. So, we hosted it elsewhere.

Fast forward to early 2018. After many years of support Andrew Snow decided
to close Octopus computing. We had a couple of months to find a new hosting
provider, migrate all our services, and shut down everything on Octopus.

So, we picked up the work that we started in 2015 with, at a high level,
a very similar approach.

## <a name='Approach'></a>Approach

- Split services into separate VMs - make each service easier to maintain on its
  own.
- Make it easy for different servers / services to be maintained by different
  people.
- Centralise the databases - a central database is easier to backup, easier
  to scale, and easier to manage.
- Use AWS but don't lock ourselves in. Make the architecture transferrable to
  any hosting provider.
- Spend a bit more money on hosting if it means less maintenance.

## <a name='Thetools'></a>The tools

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

- "provisioning" - we use this to mean configuring the server with Ansible.
- "deployment" - we use to mean installing or updating the web application with Capistrano.

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
- morph.io - automated server configuration using Ansible at
  <https://github.com/openaustralia/morph/tree/master/provisioning>

If it makes sense we might move cuttlefish and morph.io to AWS as well.

## <a name='Requirements'></a>Requirements

### <a name='Prerequisites'></a>Prerequisites

- For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/) and a supported provider - our instructions assume [VirtualBox](https://developer.hashicorp.com/vagrant/docs/providers/virtualbox).
- In order to run Ansible, you'll need Python < 3.12 installed
  - 3.12 dropped some deprecated language features which cause [Ansible 2.9 and 2.10 to no longer work](https://github.com/ansible/ansible/issues/81946).
  - Secrets: Ansible passphrases are read from the OAF 1Password account. See [Add the Ansible Vault password](#add-the-ansible-vault-password) below.
- In order to run Capistrano, you'll need a version of Ruby installed; even better, install [rbenv](https://rbenv.org/) so that you're able to manage multiple versions of Ruby.
- For deploying code onto dev/test/prod machines, you'll need [capistrano](http://capistranorb.com/)
- For a few things, including major PlanningAlerts deployments, you'll need [Terraform](https://developer.hashicorp.com/terraform/install). Terraform reads its AWS and Google credentials from your own CLI tooling — see [CLI tools for credentials](#cli-tools-for-credentials) below. The shared secrets — the RDS admin password and the Cloudflare and Linode API tokens — are rendered into `terraform/secrets.auto.tfvars` from 1Password by `make tf-secrets`.
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

#### <a name='CLItoolsforcredentials'></a>CLI tools for credentials

Operator credentials (AWS, Google) aren't stored in this repo or 1Password — each tool reads from your own CLI configuration. The Cloudflare and Linode provider tokens are the exception: they're shared service tokens kept in the **DevOps** 1Password vault and rendered by `make tf-secrets`. Install and configure the ones you need:

- **1Password CLI (`op`)** — required to read the shared Ansible Vault passphrases and the RDS admin password.
  - Install: `brew install --cask 1password-cli` on macOS, or the [official package](https://developer.1password.com/docs/cli/get-started) on Linux.
  - The CLI normally inherits a session from the 1Password desktop app. If you're running headless, sign in once with `op signin --account oaforgau`.
  - Ask an existing admin to add you to the **DevOps** vault.
- **AWS CLI (`aws`)** — required for Terraform's AWS provider and for reading S3-backed Terraform state. Configure with whichever AWS auth method we're currently using (`aws configure sso`, `aws configure`, etc.).
- **Google Cloud SDK (`gcloud`)** — required for Terraform's Google provider. After install, run `gcloud auth application-default login`.
- **Cloudflare and Linode API tokens** — no per-operator setup. These are shared service tokens stored in the **DevOps** 1Password vault (item _Terraform DB Passwords_); `make tf-secrets` renders them into `terraform/secrets.auto.tfvars` and the providers read them from there. You no longer need to export `CLOUDFLARE_API_TOKEN` or `LINODE_TOKEN`.

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

## <a name='Deploying'></a>Deploying

### <a name='DeployingRightToKnowtoyourlocaldevelopmentserver'></a>Deploying Right To Know to your local development server

If you haven't already, check out our [Alaveteli Repo](https://github.com/openaustralia/alaveteli).

In your checked out (`production` branch) of the Alaveteli repo add the following to `config/deploy.yml`

```yaml
production:
  branch: production
  repository: https://github.com/openaustralia/alaveteli.git
  server: righttoknow.org.au
  user: deploy
  deploy_to: /srv/www/production
  rails_env: production
  daemon_name: alaveteli-production
staging:
  branch: staging
  repository: https://github.com/openaustralia/alaveteli.git
  server: righttoknow.org.au
  user: deploy
  deploy_to: /srv/www/staging
  rails_env: production
  daemon_name: alaveteli-staging
development:
  branch: production
  repository: https://github.com/openaustralia/alaveteli.git
  server: righttoknow.test
  user: deploy
  deploy_to: /srv/www/production
  rails_env: production
  daemon_name: alaveteli-production

```

This adds an extra staging for the capistrano deploy called `development`. This will deploy to your
local development VM being managed by Vagrant.

Then

```
bundle exec cap -S stage=development deploy:setup
bundle exec cap -S stage=development deploy:cold
bundle exec cap -S stage=development deploy:migrate
# The step below doesn't work anymore
bundle exec cap -S stage=development xapian:rebuild_index
```

### <a name='DeployingPlanningAlerts'></a>Deploying PlanningAlerts

After provisioning, deploy from the [PlanningAlerts repository](https://github.com/openaustralia/planningalerts-app/).

#### <a name='DeployingPlanningAlertstoyourlocaldevelopmentserver'></a>Deploying PlanningAlerts to your local development server

The first time run:

```
bundle exec cap development deploy:setup deploy:cold foreman:start
```

Thereafter:

```
bundle exec cap development deploy
```

#### <a name='DeployingPlanningAlertstoproduction'></a>Deploying PlanningAlerts to production

We now have two productions servers, and a blue/green deployment process driven
out of Terraform. We use this only for major updates, when we're being cautious
and want to ensure no downtime. For smaller changes, just use capistrano as usual.

AMI images for the servers are built with Packer - look in the `packer/`
subdirectory for more details on how to build.

Once you have a new image, you'll need to adjust the `_ami_name` variables in
`terraform/main.tf` to update the not-currently-used cluster; then tweak
values in the blue/green modules in `terraform/planningalerts/main.tf` to
adjust where traffic is going. Don't forget that you'll need to
`terraform apply` at each stage of the change.

```
bundle exec cap production deploy
```

### <a name='Runningtestslocally'></a>Running tests locally

- requires a database. Use `mysql.test` from the `infrastructure` repo.
- Create a user called `pw_test` with password `pw_test` and grant it access to a db called `pw_test`. Then, drop this in `config/database.yml`:

````
test:
  adapter: mysql2
  database: pw_test
  username: pw_test
  password: pw_test
  host: mysql.test
  pool: 5
  timeout: 5000
````

- Initialize the DB before running tests:

````
RAILS_ENV=test bundle exec rakedb:create db:migrate
````

- Now you can `bundle exec rake` to run tests.

### <a name='DeployingTheyVoteForYou'></a>Deploying They Vote For You

After provisioning, set up and deploy from the
[Public Whip repository](https://github.com/openaustralia/publicwhip/)
using Capistrano:

#### <a name='DeployingTheyVoteForYoutoyourlocaldevelopmentserver'></a>Deploying They Vote For You to your local development server

If deploying for the first time:

```
bundle exec cap development deploy app:db:seed app:searchkick:reindex:all
```

Thereafter:

```
bundle exec cap development deploy
```

#### <a name='DeployingTheyVoteForYoutoproduction'></a>Deploying They Vote For You to production

```
bundle exec cap production deploy
```

### <a name='DeployingOpenAustralia'></a>Deploying OpenAustralia

After provisioning, set up the database and deploy from the OpenAustralia repository:

#### <a name='DeployingOpenAustraliatoyourlocaldevelopmentserver'></a>Deploying OpenAustralia to your local development server

If deploying for the first time:

```
cap -S stage=development deploy deploy:setup_db
```

Thereafter:

```
cap -S stage=development deploy
```

#### <a name='DeployingOpenAustraliatoproduction'></a>Deploying OpenAustralia to production

```
cap -S stage=production deploy
```

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

There are two ways an openaustralia server is configured to catch emails.

One is to be in the group `catch_all_mail`. This
- disables sending email to the real world in msmtp,
- configures php.ini to send email to `/usr/local/bin/log_not_sendmail`

### `log_not_sendmail`

The `log_not_sendmail` command logs emails to ~/log/mail/DATE-TIME.log, keeping it to

To send email to a mail catcher on openaustralia, update the `/etc/msmstprc` file,
keeping a copy as the ansible `internal/openaustralia` role will overwite it!

Note: This will affect BOTH the production and staging environments on that server!
If you ONLY want to change staging, then add the following to the `/etc/apache2/sites-enabled` config file for staging:


```
    php_admin_value sendmail_path "msmtp --read-envelope-from -t -a mailpit"
```

You will want to add a mailpit entry:


```
account mailpit
tls off
host <mailpit.server>
port 2525
auth plain
user openaustralia
password <your-password>
host plannies-mate.thesite.info
```

Change the default if you want both production and staging to be changed:


```
account default : mailpit
#account default : cuttlefish
```

To undo this, change the default back, optionally remove the mailpit entry, and update the apache vhost config if you have changed it.

REMEMBER: Keep a copy of the files you change and copy them back after running a diff to confirm if you run ansible.
(TODO: Make it a default for setting up qa/test servers)
