# Postal mail server

The [Postal](https://github.com/postalserver/postal) mail server (postal.oaf.org.au) replaces cuttlefish. Unlike cuttlefish and morph.io, whose provisioning lives in their own application repositories, postal is assembled **and** provisioned from this repository. See [docs/adr/0002-postal-replaces-cuttlefish.md](adr/0002-postal-replaces-cuttlefish.md) for why we moved off cuttlefish.

## Setting up the server

Postal is assembled with Terraform (`terraform/postal/` - Linode instance, reverse DNS and Cloudflare DNS records) and provisioned with Ansible (`roles/internal/postal/` - Docker, MariaDB, the official [postalserver/install](https://github.com/postalserver/install) helper and Caddy for SSL termination):

    make tf-plan-target MODULE=postal   # then tf-apply-target when happy
    make check-postal
    make apply-postal

## One-off manual steps after the first provisioning run

1. Create a global admin user: SSH to the server and run `postal make-user`
2. Add the DKIM record for the return path domain: run `postal default-dkim-record` on the server and add the TXT record it prints (`postal._domainkey.rp.postal.oaf.org.au`) to `terraform/postal/dns.tf`
3. Log into <https://postal.oaf.org.au>, create an organisation and a mail server per application, and add each sending domain (which will show the per-domain SPF/DKIM records to add to that domain's `dns.tf`)
4. Generate SMTP credentials for postal's own system emails and set `postal_system_smtp_username`/`postal_system_smtp_password` (vaulted) in `group_vars/postal.yml`

## Upgrades

Upgrades are deliberately manual: bump `postal_version` in `roles/internal/postal/defaults/main.yml`, then run `postal upgrade <version>` on the server (which pulls the install helper repo and migrates the database).

## Linode SMTP port restrictions

Linode blocks SMTP ports on newly created instances for some accounts - if outbound port 25 is blocked, open a Linode support ticket to lift it.
