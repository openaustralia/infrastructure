# Right To Know

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
