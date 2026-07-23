# postal

Provisions [Postal](https://postalserver.io) on postal.oaf.org.au, our
transactional mail server replacing cuttlefish. The Linode instance, firewall
and DNS are managed in `terraform/postal/`; this role installs and configures
everything on the box.

What the role sets up:

- Docker CE, and the pinned [postalserver/install](https://github.com/postalserver/install)
  helper which provides the docker-compose file and `postal` CLI
- MariaDB (native package, bound to 127.0.0.1; root access is via unix
  socket, so there is no root password)
- Postal itself (`postal.yml`, `signing.key`, web + smtp + worker containers)
- Caddy for the web interface TLS, with a daily job that copies its Let's
  Encrypt certificate to the SMTP listener (a self-signed placeholder is
  used until the first certificate is issued)
- An iptables redirect from port 2525 (the old cuttlefish submission port,
  which all client apps still use) to the SMTP listener on port 25
- Nightly database dump plus restic offsite backup of /opt/postal

## First-time setup

1. Fill in the vaulted secrets in `group_vars/postal.yml` (instructions in
   that file) and apply Terraform so the instance and DNS exist.
2. `make check-postal`, then `make apply-postal`.
3. Verify outbound port 25 is open: `nc -zv gmail-smtp-in.l.google.com 25`
   from the box. If it is blocked, open a Linode support ticket (rDNS and
   the A record already exist, which Linode requires).
4. Create the first admin user (interactive): SSH to the box and run
   `postal make-user`.
5. Add the return-path DKIM record: run `postal default-dkim-record` on the
   box and put the `k=rsa; p=...` value in the `return_path_dkim_record`
   variable of the `postal` module (a follow-up terraform PR).
6. Log in at https://postal.oaf.org.au and work through the runbook below.

## Application setup runbook

Postal has no management API, so organisations, mail servers, credentials
and domains are created in the web interface. All of this state lives in
MariaDB and is covered by the nightly backup.

1. Create one organisation: `oaf`.
2. Create one mail server per service, all in Live mode:
   `planningalerts`, `theyvoteforyou`, `openaustralia`, `morph` (shared by
   the morph app and its Discourse forum), `oaf-wordpress`.
   Separate servers keep suppression lists, credentials, message logs and
   stats isolated per service.
3. Leave click and open tracking off on every server (we deliberately do
   not track recipients).
4. For each server, under Domains add the sending domain and follow the DNS
   checks (the SPF include and DKIM records are added to that service's
   dns.tf in a terraform PR; Postal shows the exact values):
   - planningalerts -> planningalerts.org.au
   - theyvoteforyou -> theyvoteforyou.org.au
   - openaustralia -> openaustralia.org (the app sends from
     contact@openaustralia.org, note .org not .org.au)
   - morph -> morph.io
   - oaf-wordpress -> oaf.org.au
5. For each server, under Credentials create an SMTP credential. The
   credential goes straight into the consuming app's own secret store
   (Rails encrypted credentials, morph's ansible vault, msmtprc template
   var). Don't store it anywhere else.
6. On the `planningalerts` server only, create a webhook pointing at
   `https://www.planningalerts.org.au/postal/event?key=<webhook_key>`
   subscribed to the sent / delivery failed / bounced / held events.
7. Once the oaf.org.au domain is verified, create an SMTP credential for
   Postal's own notification mail and set
   `postal_management_smtp_username` / `postal_management_smtp_password` in
   `group_vars/postal.yml`, then re-apply.

## Upgrades

Upgrading Postal is deliberately manual:

1. Bump `postal_version` in `group_vars/postal.yml` and apply (this re-pins
   the docker-compose file but does not run schema migrations).
2. On the box: `postal upgrade --version <version>` (pulls images, runs
   `postal upgrade` migrations, restarts).

Check the [Postal changelog](https://github.com/postalserver/postal/blob/main/CHANGELOG.md)
first. If the install helper repo needs updating too, bump
`postal_install_version` (a commit sha) in the role defaults.

## Backup and restore

Nightly: `backup-postal-database` dumps all databases (including the
per-server `postal-*` message databases) to /opt/postal/backup, then restic
ships /opt/postal (which also contains `signing.key` and `postal.yml`)
offsite to S3. Losing `signing.key` would change our DKIM identity and
break webhook signature verification, which is why it is also vaulted in
`group_vars/postal.yml`.

Restore = restore /opt/postal from restic, load the SQL dump into a fresh
mariadb, run this role, `postal start`.
