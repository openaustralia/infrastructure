# Automated setup and configuration for most of OpenAustralia Foundation's servers

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

## Current state of this work (as of 5 March 2018)

This repo is being used to setup and configure servers on EC2 for:
* planningalerts.org.au:
  - planningalerts.org.au
  - test.planningalerts.org.au
* theyvoteforyou.org.au:
  - theyvoteforyou.org.au
  - test.theyvoteforyou.org.au
* openaustralia.org.au:
  - openaustralia.org.au
  - test.openaustralia.org.au
  - data.openaustralia.org.au
  - software.openaustralia.org.au

kedumba (configured by hand) is currently still hosting:
* electionleaflets.org.au:
  - electionleaflets.org.au
  - test.electionleaflets.org.au
* righttoknow.org.au:
  - righttoknow.org.au
  - test.righttoknow.org.au
* cuttlefish.io
* proxying for openaustraliafoundation.org.au (to jamison)
* opengovernment.org.au

jamison (configured by hand) is currently hosting:
* openaustraliafoundation.org.au
* CiviCRM

On Linode running as separate VMs with automated server configuration:
* cuttlefish.oaf.org.au - automated server configuration using Ansible at
  https://github.com/openaustralia/cuttlefish/tree/master/provisioning
* morph.io - automated server configuration using Ansible at
  https://github.com/openaustralia/morph/tree/master/provisioning

We are actively working to complete the Ansible setups required to migrate
all running services off of kedumba and jamison. That is the immediate priority.
Then, we might consider, if it makes sense moving cuttlefish and morph.io to AWS as well.

## Requirements

### Install Vagrant, Ansible and Capistrano
For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/).
For configuration management you will need [Ansible](http://docs.ansible.com/).
For deploying code you'll need [capistrano](http://capistranorb.com/)

### Install vagrant-hostsupdater
Also
```
$ vagrant plugin install vagrant-hostsupdater
```

### Add the Ansible Vault password
Create a file in your home directory `.infrastructure_ansible_vault_pass.txt` with the secret
password used to encrypt the secret info in this repo

Install required external roles with
```
ansible-galaxy install -r roles/requirements.yml -p roles/external
```

## Generating SSL certificates for development
See certificates/README.md for more information.

## Provisioning

### Provisioning local development servers using Vagrant

In development you set up and provision a server using Vagrant. You probably only want to run
one main server and the mysql server so you can bring it up with:

    vagrant up planningalerts.org.au.dev mysql.dev

If it's already up you can re-run Ansible provisioning with:

    vagrant provision planningalerts.org.au.dev

### Provisioning production servers

Provision all running servers with:

    ansible-playbook -i ec2-hosts site.yml

If you just want to provision a single server:

    ansible-playbook -i ec2-hosts site.yml -l planningalerts

## Deploying

### Deploying Right To Know to your local development server

For the time being you will need to use the `update-rbenv-deploy` branch of the OpenAustralia
Foundation Alaveteli repo as it contains some small fixes to allow capistrano to work with rbenv.

In your checked out copy of the Alaveteli repo add the following to `config/deploy.yml`

```yaml
development:
  branch: update-rbenv-deploy
  repository: git://github.com/openaustralia/alaveteli.git
  server: righttoknow.org.au.dev
  user: deploy
  deploy_to: /srv/www/production
  rails_env: production
ec2-production:
  branch: update-rbenv-deploy
  repository: git://github.com/openaustralia/alaveteli.git
  server: ec2.righttoknow.org.au
  user: deploy
  deploy_to: /srv/www/production
  rails_env: production
ec2-staging:
  branch: update-rbenv-deploy
  repository: git://github.com/openaustralia/alaveteli.git
  server: ec2.righttoknow.org.au
  user: deploy
  deploy_to: /srv/www/staging
  rails_env: production
```

This adds an extra staging for the capistrano deploy called `development`. This will deploy to your
local development VM being managed by Vagrant.

Then
```
bundle exec cap -S stage=development deploy:setup
bundle exec cap -S stage=development deploy:cold
bundle exec cap -S stage=development deploy:migrate
bundle exec cap -S stage=development xapian:rebuild_index
```

#### TODOS

* Email

### Deploying PlanningAlerts

After provisioning, deploy from the [PlanningAlerts repository](https://github.com/openaustralia/planningalerts-app/).

#### Deploying PlanningAlerts to your local development server
The first time run:
```
bundle exec cap -S stage=development deploy:setup deploy:cold foreman:start
```

Thereafter:
```
bundle exec cap -S stage=development deploy
```

#### Deploying PlanningAlerts to production

```
bundle exec cap -S stage=production deploy
```

### Deploying Electionleaflets to your local development server

After provisioning, deploy from Electionleaflets repository
```
cap -S stage=development deploy
cap -S stage=development deploy:setup_db
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

## Don't use Google Chrome

Don't use Google Chrome for development with the openaustralia site because they helpfully (read
not helpfully and rudely) made **every single site in the .dev domain redirect to https**. So,
for the time being (until we make openaustralia redirect to use https) use Firefox instead.
