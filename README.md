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
```

This adds an extra staging for the capistrano deploy called `development`. This will deploy to your
local development VM being managed by Vagrant.

Then
```
cap -S stage=development deploy:setup
cap -S stage=development deploy:cold
cap -S stage=development deploy:migrate
cap -S stage=development xapian:rebuild_index
```

#### TODOS

* Varnish
* Xapian
* Cron jobs
* Email
* SSL
* Backups
* wkhtmltopdf
* pdftk
* Set up mail server logs so that they can be read in

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

* Django maps app
* backups

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

#### TODOS

* Backups

### Note about the custom dnsmadeeasy module

We've made some fixes to the dnsmadeeasy module which allow it work for MX and TXT records, root A
records and CNAMEs pointing to the domain root - well basically it was completely broken.

We're trying to get the [changes merged into Ansible](https://github.com/ansible/ansible-modules-extras/pull/269).

In the meantime, our updated version is used and included automatically from `custom_modules/library/dnsmadeeasy.py`
