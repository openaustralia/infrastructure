# Automated setup and configuration for most of OpenAustralia Foundation's servers

<!-- vscode-markdown-toc -->
* [A little history](#Alittlehistory)
* [Approach](#Approach)
* [The tools](#Thetools)
* [Updates](#Updates)
  * [2025-05-27](#)
  * [Supported Platforms](#SupportedPlatforms)
  *[RightToKnow Dev platform](#RightToKnowDevplatform)
  * [PlanningAlerts Production](#PlanningAlertsProduction)
    * [2018-05-26](#-1)
* [Requirements](#Requirements)
* [Prerequisites](#Prerequisites)
  * [Environment setup](#Environmentsetup)
  * [Add the Ansible Vault password](#AddtheAnsibleVaultpassword)
* [Generating SSL certificates for development](#GeneratingSSLcertificatesfordevelopment)
* [Provisioning](#Provisioning)
  * [Provisioning local development servers using Vagrant](#ProvisioninglocaldevelopmentserversusingVagrant)
  * [Provisioning production servers](#Provisioningproductionservers)
  * [Forcibly renewing LetsEncrypt certificates on production servers](#ForciblyrenewingLetsEncryptcertificatesonproductionservers)
* [Deploying](#Deploying)
  * [Deploying Right To Know to your local development server](#DeployingRightToKnowtoyourlocaldevelopmentserver)
  * [Deploying PlanningAlerts](#DeployingPlanningAlerts)
    * [Deploying PlanningAlerts to your local development server](#DeployingPlanningAlertstoyourlocaldevelopmentserver)
    * [Deploying PlanningAlerts to production](#DeployingPlanningAlertstoproduction)
  * [Running tests locally](#Runningtestslocally)
  * [Deploying Electionleaflets to your local development server](#DeployingElectionleafletstoyourlocaldevelopmentserver)
    * [TODOS](#TODOS)
  * [Deploying They Vote For You](#DeployingTheyVoteForYou)
    * [Deploying They Vote For You to your local development server](#DeployingTheyVoteForYoutoyourlocaldevelopmentserver)
    * [Deploying They Vote For You to production](#DeployingTheyVoteForYoutoproduction)
  * [Deploying OpenAustralia](#DeployingOpenAustralia)
    * [Deploying OpenAustralia to your local development server](#DeployingOpenAustraliatoyourlocaldevelopmentserver)
    * [Deploying OpenAustralia to production](#DeployingOpenAustraliatoproduction)
* [Backups](#Backups)

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
a second small VM running on Octopus which runs oaf.org.au, CiviCRM and
elasticsearch. All of these had to run on a separate VM because they required
a more recent version of the operating system.

We also created two projects that we hosted outside of Octopus, on Linode:
cuttlefish.oaf.org.au and morph.io. morph.io needed docker which couldn't run
easily on kedumba. cuttlefish is a transactional email server that we
opened up for use by the civic tech community. We didn't want to risk cuttlefish
undermining the email reputation of kedumba. So, we hosted it elsewhere.

Fast forward to early 2018. After many years of support Andrew Snow decided
to close Octopus computing. We had a couple of months to find a new hosting
provider, migrate all our services and shut down everything on Octopus.

So, we picked up the work that we started in 2015 with, at a high level,
a very similar approach.

## <a name='Approach'></a>Approach

* Split services into separate VMs - make each service easier to maintain on its
  own.
* Make it easy for different servers / services to be maintained by different
  people.
* Centralise the databases - a central database is easier to backup, easier
  to scale and easier to manage.
* Use AWS but don't lock ourselves in. Make the architecture transferrable to
  any hosting provider.
* Spend a bit more money on hosting if it means less maintenance.

## <a name='Thetools'></a>The tools

To get a completely working server and service up and running requires a number
of different tools. We use different tools for different things.

* Terraform: To spin up servers, manage DNS and IP addresses and setting up any
  related AWS infrastructure
* Ansible: To configure individual servers - install packages, create directory
  structures, install SSL certificates, configure cron jobs, create databases,
  etc..
* Vagrant: For local development of the Ansible setups for the servers. The
  vagrant boxes are not designed for doing application development. For that
  go to the individual application repositories.
* Capistrano: For application deployment. This is what installs the actual
  web application and updates the database schema.

Each application has its own repository and this is where application deployment
is done from. This repository just contains the Terraform and Ansible configuration
for the servers.

A little note on terminology:

* "provisioning" - we use this to mean configuring the server with Ansible.
* "deployment" - we use to mean installing or updating the web application with Capistrano.

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

* planningalerts.org.au:
  * planningalerts.org.au
  * test.planningalerts.org.au
  * A cron job that uploads planningalerts data for a commercial client
* theyvoteforyou.org.au:
  * theyvoteforyou.org.au
  * test.theyvoteforyou.org.au
* openaustralia.org.au:
  * openaustralia.org.au
  * test.openaustralia.org.au
  * data.openaustralia.org.au
  * software.openaustralia.org.au
* righttoknow.org.au:
  * righttoknow.org.au
  * test.righttoknow.org.au
* openaustraliafoundation.org.au:
  * openaustraliafoundation.org.au
  * CiviCRM
* opengovernment.org.au
* electionleaflets.org.au:
  * electionleaflets.org.au
  * test.electionleaflets.org.au

On Linode running as separate VMs with automated server configuration:

* cuttlefish.oaf.org.au - automated server configuration using Ansible at
  <https://github.com/mlandauer/cuttlefish/tree/master/provisioning>
* morph.io - automated server configuration using Ansible at
  <https://github.com/openaustralia/morph/tree/master/provisioning>

If it makes sense we might move cuttlefish and morph.io to AWS as well.

## <a name='Requirements'></a>Requirements

### <a name='Prerequisites'></a>Prerequisites

* For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/) and a supported provider - our instructions assume [VirtualBox](https://developer.hashicorp.com/vagrant/docs/providers/virtualbox).

* In order to run Ansible, you'll need Python < 3.12 installed
  * 3.12 dropped some deprecated language features which cause [Ansible 2.9 and 2.10 to no longer work](https://github.com/ansible/ansible/issues/81946).
  * Secrets: Ansible looks at the four symlinks in the root of this repo and expects to find passphrases to unlock secrets used for production deployments. Our usual method of distributing these files is documented [below](#add-the-ansible-vault-password). If Keybase isn't working for you, any technique you have to put the right value into the right file will be fine. You may need to update the `vault_identity_list` in [ansible.cfg](https://github.com/openaustralia/infrastructure/blob/master/ansible.cfg) to point at your new location.
* In order to run Capistrano, you'll need a version of Ruby installed; even better, install [rbenv](https://rbenv.org/) so that you're able to manage multiple versions of Ruby.
* For deploying code onto dev/test/prod machines, you'll need [capistrano](http://capistranorb.com/)
* For a few things, including major PlanningAlerts deployments, you'll need [Terraform](https://developer.hashicorp.com/terraform/install)
  * Terraform requires some extra secrets to access the S3 bucket we use to store Terraform's permanent state. You can put these in the usual place that AWS CLI tools look - `~/.aws/credentials`.
  * Terraform requires some extra secrets in addition to those used by Ansible. Ask James about secrets.auto.tfvars
    * Note that some of these secrets are the same secrets used as AWS credentials above, but they'll need to be provided again to populate the Terraform variables as well
  * Terraform requires that you have [the gCloud CLI](https://cloud.google.com/sdk/docs/install) set up and configured with authentication credentials it can use. `gcloud auth application-default login`
  * Terraform runs `prepkey.sh` to grab your SSH public key to use as a deployer key in AWS. This script makes some simple assumptions: that `jq` is installed, and that your public key can be found at `~/.ssh/id_rsa.pub`.
  * We host DNS on Cloudflare. An API key to manage these zones is one of the secrets you'll need to provide. To get access to the configs in the [Cloudflare dashboard](https://dash.cloudflare.com), you'll need access to the organisation - see Matthew or James for details

### <a name='Environmentsetup'></a>Environment setup

There's a very handy `Makefile` included which will:

* install Vagrant plugins
* Create a python virtual environment
* Install `ansible-galaxy` roles and collections

Simply run

```sh
make
```

### <a name='AddtheAnsibleVaultpassword'></a>Add the Ansible Vault password

Ansible Vault secrets are distributed via
[Keybase](https://keybase.io). Before you can push to production
servers, you'll need to be added to the appropriate teams.

You'll need to have Keybase installed on the machine where you run
ansible.

If this system has a gui, you'll need to enable "Finder integration"
or the equivalent on your platform, under Settings -> Files.

If your system does _not_ have a GUI - for instance, it's a WSL instance on
windows; or a remote Ubuntu VM running headless - there's a helper script
at `bin/headless-keybase.sh` which will help you run the Keybase services
as user-space systemd units.

The first time you run `make`, it will try to create `.keybase` as a symlink to
the place where Keybase makes the files available. This is often `/keybase` on
linux desktops. On headless systems it might be under `/run/user/`.

For Mac users, you may need to run `make macos-keybase`, which forces the `.keybase`
folder to symlink to `/Volumes/Keybase`.

Once this is done, the symlinks to .*-vault-pass inside the repo
should point to the password files. If this doesn't work you may need to update these files yourself.

## <a name='GeneratingSSLcertificatesfordevelopment'></a>Generating SSL certificates for development

See certificates/README.md for more information. This also generates a certificate for morph local development if present.

## <a name='Provisioning'></a>Provisioning

### <a name='ProvisioninglocaldevelopmentserversusingVagrant'></a>Provisioning local development servers using Vagrant

In development you set up and provision a server using Vagrant. You probably only want to run
one main server and the mysql server so you can bring it up with:

    vagrant up web1.planningalerts.org.au.test mysql.test

If it's already up you can re-run Ansible provisioning with:

    vagrant provision web1.planningalerts.org.au.test

### <a name='Provisioningproductionservers'></a>Provisioning production servers

Provision all running servers with:

```sh
    make production
```

This will create a Python virtualenv in `venv`; install ansible inside it; and install required roles from ansible-galaxy inside `roles/external`

If you just want to provision a single server:

```sh
    .venv/bin/ansible-playbook -i ec2-hosts site.yml -l planningalerts
```

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
  server: righttoknow.org.au.test
  user: deploy
  deploy_to: /srv/www/production
  rails_env: production
  daemon_name: alaveteli-production

```

This adds an extra staging for the capistrano deploy called `development`. This will deploy to your
local development VM being managed by Vagrant.

Then

```sh
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

```sh
bundle exec cap development deploy:setup deploy:cold foreman:start
```

Thereafter:

```sh
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

```sh
bundle exec cap production deploy
```

### <a name='Runningtestslocally'></a>Running tests locally

* requires a database. Use `mysql.test` from the `infrastructure` repo.
* Create a user called `pw_test` with password `pw_test` and grant it access to a db called `pw_test`. Then, drop this in `config/database.yml`:

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

* Intialize the DB before running tests:

````
RAILS_ENV=test bundle exec rakedb:create db:migrate
````

* Now you can `bundle exec rake` to run tests.

### <a name='DeployingElectionleafletstoyourlocaldevelopmentserver'></a>Deploying Electionleaflets to your local development server

After provisioning, deploy from Electionleaflets repository

```sh
bundle exec cap -S stage=development deploy
bundle exec cap -S stage=development deploy:setup_db
```

#### <a name='TODOS'></a>TODOS

* Django maps app (not worth doing?)

### <a name='DeployingTheyVoteForYou'></a>Deploying They Vote For You

After provisioning, set up and deploy from the
[Public Whip repository](https://github.com/openaustralia/publicwhip/)
using Capistrano:

#### <a name='DeployingTheyVoteForYoutoyourlocaldevelopmentserver'></a>Deploying They Vote For You to your local development server

If deploying for the first time:

```sh
bundle exec cap development deploy app:db:seed app:searchkick:reindex:all
```

Thereafter:

```sh
bundle exec cap development deploy
```

#### <a name='DeployingTheyVoteForYoutoproduction'></a>Deploying They Vote For You to production

```sh
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
