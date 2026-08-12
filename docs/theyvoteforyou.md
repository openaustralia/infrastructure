**Table of Contents**

# They Vote For You

<!-- vscode-markdown-toc -->
- [They Vote For You](#they-vote-for-you)
  - [Running tests locally](#running-tests-locally)
  - [Deploying They Vote For You](#deploying-they-vote-for-you)
    - [Deploying They Vote For You to your local development server](#deploying-they-vote-for-you-to-your-local-development-server)
    - [Deploying They Vote For You to production](#deploying-they-vote-for-you-to-production)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

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
