**Table of Contents**

# OpenAustralia

<!-- vscode-markdown-toc -->
- [OpenAustralia](#openaustralia)
    - [Deploying OpenAustralia](#deploying-openaustralia)
      - [Deploying OpenAustralia to your local development server](#deploying-openaustralia-to-your-local-development-server)
      - [Deploying OpenAustralia to production](#deploying-openaustralia-to-production)
  - [Mail Catching](#mail-catching)
    - [`log_not_sendmail`](#log_not_sendmail)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

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

## <a name='MailCatching'></a>Mail Catching

There are two ways an openaustralia server is configured to catch emails.

One is to be in the group `catch_all_mail`. This
- disables sending email to the real world in msmtp,
- configures php.ini to send email to `/usr/local/bin/log_not_sendmail`

### `log_not_sendmail`

The `log_not_sendmail` command logs emails to ~/log/mail/DATE-TIME.log, keeping it to

To send email to a mail catcher on openaustralia, update the `/etc/msmstprc` file,
keeping a copy as the ansible `internal/openaustralia` role will overwite it!

Note: This will affect BOTH the production and staging stages on that host!
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

Change the default if you want both stages to be changed:


```
account default : mailpit
#account default : cuttlefish
```

To undo this, change the default back, optionally remove the mailpit entry, and update the apache vhost config if you have changed it.

REMEMBER: Keep a copy of the files you change and copy them back after running a diff to confirm if you run ansible.
(TODO: Make it a default for setting up qa/test servers)
