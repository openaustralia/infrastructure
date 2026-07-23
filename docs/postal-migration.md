# Cuttlefish to Postal migration

We are replacing [cuttlefish](https://cuttlefish.oaf.org.au), our
transactional mail server (a hand-provisioned Ubuntu 14.04 Linode that is
not managed by ansible), with [Postal](https://postalserver.io) v3 on a new
ansible-managed Linode at postal.oaf.org.au.

Cuttlefish currently relays mail for:

- Planning Alerts (also uses cuttlefish-specific headers and its delivery
  event webhook for bounce handling)
- They Vote For You
- OpenAustralia.org.au (via msmtp, configured by this repo)
- morph.io (the app and its Discourse forum, configured by the morph repo)
- oaf.org.au (the WordPress.com site)

Right to Know does not use cuttlefish (it runs its own postfix).

## How the migration works

Cuttlefish keeps running untouched until every service has moved. All DNS
changes are additive while the two servers coexist (each sending domain
gains a Postal DKIM record and `include:spf.postal.oaf.org.au` alongside
its cuttlefish records). Each service then cuts over individually by
swapping SMTP host and credentials, so rollback for any service is just
restoring the old credential - no DNS involved.

Services move in ascending order of volume/risk, which also warms up the
new IP's sending reputation before the biggest sender moves:

1. They Vote For You staging (free rehearsal, same config shape as
   production)
2. They Vote For You production
3. morph.io (morph repo PR: `provisioning/group_vars/production.yml` plus
   the morph-app and discourse templates; morph's alert emails also rely on
   cuttlefish's CSS inlining which Postal doesn't do, so that PR needs
   premailer or accepts plainer styling)
4. oaf.org.au WordPress (manual: find the SMTP plugin settings in wp-admin
   first, then swap host/credentials)
5. OpenAustralia (this repo: msmtprc template + group_vars; also turn
   certificate checking back on since postal has a valid certificate)
6. Planning Alerts last, 2-3 weeks after the others: it is the highest
   volume sender and needs app changes first (X-Postal-Tag headers, a new
   /postal/event webhook controller for bounce handling, MessageHeld Slack
   notifications). Those ship in their own planningalerts PR before the
   credential swap.

Per-cutover verification: send a test mail to a Gmail-hosted address and
check spf/dkim/dmarc all pass with the postal DKIM selector, check the
message log in the Postal UI, and watch the domain's sending source shift
from the cuttlefish IP to the postal IP in the Suped DMARC dashboard over
the following days.

## Decommissioning cuttlefish

Only after all services have moved and 2-4 weeks of watching the cuttlefish
UI for stragglers (it was historically open to the civic tech community):

1. Remove cuttlefish credentials/config from the app repos, the
   /cuttlefish/event webhook from planningalerts, and the `cuttlefish_*`
   vars from group_vars/openaustralia.yml.
2. Terraform: remove `ip4:<cuttlefish>` from the `_spf1.oaf.org.au` record,
   `a:cuttlefish.oaf.org.au` from the planningalerts SPF, every
   `*.cuttlefish._domainkey.*` TXT record, the `email.morph.io` /
   `email2.morph.io` / `email2.planningalerts.org.au` CNAMEs, and finally
   the `cuttlefish` module itself.
3. Take a final Linode snapshot and database dump first - the delivery
   history is worth keeping.

## Where things live

- Server + firewall + per-server DNS: `terraform/postal/`
- Provisioning: `roles/internal/postal/` (see its README for the
  application setup runbook, upgrades, backup/restore)
- Secrets: `group_vars/postal.yml` (ansible-vault)
- Per-service DNS: each service's own `dns.tf` (added at cutover time)
