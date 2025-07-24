# Automated setup and configuration for most of OpenAustralia Foundation's servers
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Automated setup and configuration for most of OpenAustralia Foundation's servers](#automated-setup-and-configuration-for-most-of-openaustralia-foundations-servers)
    - [A little history](#a-little-history)
    - [Approach](#approach)
    - [The tools](#the-tools)
    - [Current state of this work (as of 26 May 2018)](#current-state-of-this-work-as-of-26-may-2018)
    - [Requirements](#requirements)
        - [Install Vagrant and Capistrano](#install-vagrant-and-capistrano)
        - [Environment setup](#environment-setup)
        - [Add the Ansible Vault password](#add-the-ansible-vault-password)
    - [Generating SSL certificates for development](#generating-ssl-certificates-for-development)
    - [Provisioning](#provisioning)
        - [Provisioning local development servers using Vagrant](#provisioning-local-development-servers-using-vagrant)
        - [Provisioning production servers](#provisioning-production-servers)
        - [Forcibly renewing LetsEncrypt certificates on production servers](#forcibly-renewing-letsencrypt-certificates-on-production-servers)
    - [Deploying](#deploying)
        - [Deploying Right To Know to your local development server](#deploying-right-to-know-to-your-local-development-server)
        - [Deploying PlanningAlerts](#deploying-planningalerts)
            - [Deploying PlanningAlerts to your local development server](#deploying-planningalerts-to-your-local-development-server)
            - [Deploying PlanningAlerts to production](#deploying-planningalerts-to-production)
        - [Running tests locally](#running-tests-locally)
    - [Backups](#backups)

<!-- markdown-toc end -->

## A little history

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

## Approach

* Split services into separate VMs - make each service easier to maintain on its
  own.
* Make it easy for different servers / services to be maintained by different
  people.
* Centralise the databases - a central database is easier to backup, easier
  to scale and easier to manage.
* Use AWS but don't lock ourselves in. Make the architecture transferrable to
  any hosting provider.
* Spend a bit more money on hosting if it means less maintenance.

## The tools

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

## Current state of this work (as of 26 May 2018)

This repo is being used to setup and configure servers on EC2 for:
* planningalerts.org.au:
  - planningalerts.org.au
  - test.planningalerts.org.au
  - A cron job that uploads planningalerts data for a commercial client
* theyvoteforyou.org.au:
  - theyvoteforyou.org.au
  - test.theyvoteforyou.org.au
* openaustralia.org.au:
  - openaustralia.org.au
  - test.openaustralia.org.au
  - data.openaustralia.org.au
  - software.openaustralia.org.au
* righttoknow.org.au:
  - righttoknow.org.au
  - test.righttoknow.org.au
* openaustraliafoundation.org.au:
  - openaustraliafoundation.org.au
  - CiviCRM
* opengovernment.org.au
* electionleaflets.org.au:
  - electionleaflets.org.au
  - test.electionleaflets.org.au

On Linode running as separate VMs with automated server configuration:
* cuttlefish.oaf.org.au - automated server configuration using Ansible at
  https://github.com/mlandauer/cuttlefish/tree/master/provisioning
* morph.io - automated server configuration using Ansible at
  https://github.com/openaustralia/morph/tree/master/provisioning

If it makes sense we might move cuttlefish and morph.io to AWS as well.

## Requirements

### Install Vagrant and Capistrano
For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/).
For deploying code you'll need [capistrano](http://capistranorb.com/)
You'll need Python 2.6 or 2.7 and virtualenv installed by your OS package manager.

### Environment setup

There's a very handy `Makefile` included which will:
- install Vagrant plugins
- Create a python virtual environment
- Install `ansible-galaxy` roles

Simply run

```
$ make
```

### Add the Ansible Vault password

Ansible Vault secrets are distributed via
[Keybase](https://keybase.io). Before you can push to production
servers, you'll need to be added to the appropriate teams.

You'll need to have Keybase installed on the machine where you run
ansible. You'll need to enable "Finder integration" or the equivalent
on your platform, under Settings -> Files.

Once this is done, the symlinks to .*-vault-pass inside the repo
should point to the password files.

(Note on OS X and keybase 5.3.0 the symlinks point to the wrong place. The keybase filesystem now starts at /Volumes/Keybase rather than /keybase)

## Generating SSL certificates for development
See certificates/README.md for more information.

## Provisioning

### Provisioning local development servers using Vagrant

In development you set up and provision a server using Vagrant. You probably only want to run
one main server and the mysql server so you can bring it up with:

    vagrant up web1.planningalerts.org.au.test mysql.test

If it's already up you can re-run Ansible provisioning with:

    vagrant provision web1.planningalerts.org.au.test

### Provisioning production servers

Provision all running servers with:

    make production

This will create a Python virtualenv in `venv`; install ansible inside it; and install required roles from ansible-galaxy inside `roles/external`

If you just want to provision a single server:

    .venv/bin/ansible-playbook -i ec2-hosts site.yml -l planningalerts

### Forcibly renewing LetsEncrypt certificates on production servers

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

## Deploying

### Deploying Right To Know to your local development server

In your checked out copy (`production` branch) of the Alaveteli repo add the following to `config/deploy.yml`

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
```
bundle exec cap -S stage=development deploy:setup
bundle exec cap -S stage=development deploy:cold
bundle exec cap -S stage=development deploy:migrate
# The step below doesn't work anymore
bundle exec cap -S stage=development xapian:rebuild_index
```

### Deploying PlanningAlerts

After provisioning, deploy from the [PlanningAlerts repository](https://github.com/openaustralia/planningalerts-app/).

#### Deploying PlanningAlerts to your local development server
The first time run:
```
bundle exec cap development deploy:setup deploy:cold foreman:start
```

Thereafter:
```
bundle exec cap development deploy
```

#### Deploying PlanningAlerts to production

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

### Running tests locally

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
- Intialize the DB before running tests:
````
RAILS_ENV=test bundle exec rakedb:create db:migrate
````
- Now you can `bundle exec rake` to run tests.

### Deploying Electionleaflets to your local development server

After provisioning, deploy from Electionleaflets repository
```
bundle exec cap -S stage=development deploy
bundle exec cap -S stage=development deploy:setup_db
```

#### TODOS

* Django maps app (not worth doing?)

### Deploying They Vote For You

After provisioning, set up and deploy from the
[Public Whip repository](https://github.com/openaustralia/publicwhip/)
using Capistrano:

#### Deploying They Vote For You to your local development server
If deploying for the first time:
```
bundle exec cap development deploy app:db:seed app:searchkick:reindex:all
```

Thereafter:
```
bundle exec cap development deploy
```

#### Deploying They Vote For You to production

```
bundle exec cap production deploy
```

### Deploying OpenAustralia

After provisioning, set up the database and deploy from the OpenAustralia repository:

#### Deploying OpenAustralia to your local development server
If deploying for the first time:
```
cap -S stage=development deploy deploy:setup_db
```

Thereafter:
```
cap -S stage=development deploy
```

#### Deploying OpenAustralia to production

```
cap -S stage=production deploy
```

## Backups

Data directories of servers are backed up to S3 using Duply.

Using the `data_directory` profile as an example, to run a backup manually you'd log in as root and run `duply data_directory backup`.

To restore the latest backup to `/mnt/restore` you'd run `duply data_directory restore /mnt/restore`.
