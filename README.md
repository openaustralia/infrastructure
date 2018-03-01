# Ansible configuration management for all of OpenAustralia Foundation's servers

** THIS IS A WORK IN PROGRESS **

It is (as of 19 Feb 2018) being used to setup and configure servers for:
* planningalerts
* theyvoteforyou

The other sites are being worked on right now.

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
    * opengovernment.org.au
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
For deploying code you'll need [capistrano](http://capistranorb.com/)

Also
```
$ vagrant plugin install vagrant-hostsupdater
```

Create a file in your home directory `.infrastructure_ansible_vault_pass.txt` with the secret
password used to encrypt the secret info in this repo

Install required external roles with
```
ansible-galaxy install -r roles/requirements.yml -p roles/external
```

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
using Capistrano:

On ec2 (if deploying for the first time)
```
bundle exec cap ec2 deploy app:db:seed app:searchkick:reindex:all
```

TODO: Deploying for development

### OpenAustralia

After provisioning, set up the database and deploy from the OpenAustralia repository:
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

#### Don't use Google Chrome

Don't use Google Chrome for development with the openaustralia site because they helpfully (read
not helpfully and rudely) made **every single site in the .dev domain redirect to https**. So,
for the time being (until we make openaustralia redirect to use https) use Firefox instead.

## Backups

Data directories of servers are backed up to S3 using Duply. For most servers this means backing up the automysqlbackup directory.

Using the `automysqlbackup` profile as an example, to run a backup manually you'd log in as root and run `duply automysqlbackup backup`.

To restore the latest backup to `/mnt/restore` you'd run `duply automysqlbackup restore /mnt/restore`.

## Generating CA certificates and SSL certificates

See certificates/README.md for more information.

## Database migration

To do the database migration from kedumba to RDS we're making use of the database migration service
on AWS. To access the database on kedumba (which is not exposed to the internet) we need to setup
an SSH tunnel. Using theyvoteforyou server on EC2 to do this:
As the `deploy` user,
```
ssh-keygen -t rsa
```
Then copy the public key over to kedumba and put it in `~/.ssh/authorized_keys`. Then,
```
apt install autossh
autossh -p 2506 deploy@kedumba.oaf.org.au -N -L 0.0.0.0:3306:localhost:3306 &
```
