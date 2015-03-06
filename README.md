# Ansible configuration management for all of OpenAustralia Foundation's servers

** THIS IS A WORK IN PROGRESS **

We currently use four servers with the following websites running on each server:

1. Linode server 1:
  * cuttlefish.oaf.org.au
2. Linode server 2:
  * morph.io
3. Octopus Computing (kedumba) - The main server:
  * Production sites:
    * openaustralia.org.au
    * data.openaustralia.org
    * planningalerts.org.au
    * electionleaflets.org.au
    * righttoknow.org.au
    * theyvoteforyou.org.au
    * unannounced (as yet) site for nsw
    * cuttlefish.io
    * proxying for openaustraliafoundation.org.au
  * Staging sites:
    * test.openaustralia.org
    * test.planningalerts.org.au
    * test.electionleaflets.org.au
    * test.righttoknow.org.au
    * test.theyvoteforyou.org.au
4. Octopus Computing (jamison):
  * openaustraliafoundation.org.au with CiviCRM

We need to do an OS upgrade on kedumba. We are taking the oppurtunity to do a long needed rethink of our server setup.

Our current plan is to separate the different sites currently running on kedumba into separate servers with our entire setup being managed by Ansible.

## Some useful reading

* [6 practices for super smooth Ansible experience](http://hakunin.com/six-ansible-practices)
* [Ansible Best Practices](http://docs.ansible.com/playbooks_best_practices.html)
* [Ansible real life good practices](https://www.reinteractive.net/posts/167-ansible-real-life-good-practices)

## Requirements

For starting local VMs for testing you will need [Vagrant](https://www.vagrantup.com/).
For configuration management you will need [Ansible](http://docs.ansible.com/).

Also
```
$ vagrant plugin install vagrant-hostsupdater
```

Create a file in your home directory `.infrastructure_ansible_vault_pass.txt` with the secret
password used to encrypt the secret info in this repo

## Provisioning

### Development

In development you set up and provision a server using Vagrant. You probably only want to run
one machine so you can bring it up with:

    vagrant up righttoknow.org.au.dev

If it's already up you can re-run Ansible provisioning with:

    vagrant provision righttoknow.org.au.dev

### Staging

**This is untested**

Provision a running server with:

    ansible-playbook site.yml -i staging --limit=righttoknow

## Notes for deploying

### Right To Know

For the time being you will need to use the `update-rbenv-deploy` branch of the OpenAustralia
Foundation Alaveteli repo as it contains some small fixes to allow capistrano to work with rbenv.

In your checked out copy of the Alaveteli repo add the following to `config/deploy.yml`

```yaml
development:
  branch: update-rbenv-deploy
  repository: git://github.com/openaustralia/alaveteli.git
  server: righttoknow.org.au.dev
  user: deploy
  deploy_to: /srv/www
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

* Varnish
* Email

### PlanningAlerts

After provisioning, deploy from the [PlanningAlerts repository](https://github.com/openaustralia/planningalerts-app/):

```
bundle exec cap -S stage=development deploy:setup deploy:cold foreman:start
```

### Electionleaflets

After provisioning, deploy from Electionleaflets repository
```
cap -S stage=development deploy
cap -S stage=development deploy:setup_db
```

#### TODOS

* Django maps app (not worth doing?)

### They Vote For You

After provisioning, set up and deploy from the
[Public Whip repository](https://github.com/openaustralia/publicwhip/)
using **Mina**:

```
bundle exec mina setup
bundle exec mina deploy
# Optionally load seed data (the home page crashes with no data)
bundle exec mina rake[db:seed]
# Optionally build index so search works
bundle exec mina rake[searchkick:reindex:all]
```

### OpenAustralia

After provision, set up the database and deploy from the OpenAustralia repository:
```
cap -S stage=development deploy
cap -S stage=development deploy:setup_db
```

#### TODOS

* Email (test sending, setup Cuttlefish)
* Cronjobs
* Set up data.openaustralia.org
* Backups
* HTTPS
* Staging/production web server config

## DNS Setup

We're using Ansible to setup DNS for each project. The tasks that do that are currently in the
associated role. So, for instance the tasks to setup the oaf.org.au domain are in the `oaf` role.

All the tasks use a default ttl of 1800 seconds (30 mins). Before changing anything drop the ttl to
something like 300 seconds (5 mins) or 60 seconds (1 min) so that any changes you make will
propagate quickly. Now wait around 1 hour.

Let's say we have the following line in one of the tasks for setting up the DNS
```
- {type: "CNAME", name: "test", value: ""}
```

This says make `test` a `CNAME` for the root of the domain. Let's say we want to change that so
it points to another domain `foo.com`.

Simply change the line to read
```
- {type: "CNAME", name: "test", value: "foo.com."}
```
And rerun ansible (or Vagrant).

Ansible will see that there is already a record for `CNAME` `test` and change that to its new value.

For records that can have multiple values per type such as `TXT` records it works a little differently.
It will only treat something as the same record if it has the same value as well.

So, for instance you can remove a particular `TXT` record by doing
```
dnsmadeeasy: account_key=xxxx account_secret=xxxx domain="foo.com" record_ttl=1800 state=absent record_name="" record_type="TXT" record_value='"v=spf1 a include:_spf.google.com ~all"'
```

but if I do
```
dnsmadeeasy: account_key=xxxx account_secret=xxxx domain="foo.com" record_ttl=1800 state=present record_name="" record_type="TXT" record_value='some text'
```

it will always add a new record unless there is already a `TXT` record with the value `some text` on the
root of the domain.

To add a new domain, first you will need to add the domain in [DNSMadeEasy web console](https://cp.dnsmadeeasy.com/). Then, you can copy the Ansible dnsmadeeasy task template from any of the roles that use it remembering to change the `domain=` parameter to the new domain name.

## Note about the custom dnsmadeeasy module

We've made some fixes to the dnsmadeeasy module which allow it work for MX and TXT records, root A
records and CNAMEs pointing to the domain root - well basically it was completely broken.

We're trying to get the [changes merged into Ansible](https://github.com/ansible/ansible-modules-extras/pull/269).

In the meantime, our updated version is used and included automatically from `custom_modules/library/dnsmadeeasy.py`

## Backups

Data directories of servers are backed up to S3 using Duply. For most servers this means backing up the automysqlbackup directory.

Using the `automysqlbackup` profile as an example, to run a backup manually you'd log in as root and run `duply automysqlbackup backup`.

To restore the latest backup to `/mnt/restore` you'd run `duply automysqlbackup restore /mnt/restore`.
