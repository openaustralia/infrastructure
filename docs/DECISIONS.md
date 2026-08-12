# Decisions

Cross-cutting engineering decisions and directives that aren't tied to one file or area, so a comment alone
wouldn't surface them. A decision local to one file/role/module belongs as a comment there instead, explaining why.

Append new entries at the top. Don't edit past entries except to mark them superseded (and say by what).

## 2026-08-11 - Cuttlefish is being replaced by Postal, provisioned from this repo

Cuttlefish uses oaf.org.au as the Return-Path for every sending domain, which breaks DMARC alignment for
planningalerts.org.au and morph.io and blocks moving any of our DMARC policies past `p=none`
([#365](https://github.com/openaustralia/infrastructure/issues/365)). Rather than upgrade cuttlefish (barely
maintained, needs a software upgrade just to fix the Return-Path), we're migrating to
[Postal](https://github.com/postalserver/postal), which handles per-domain return paths, DKIM and deliverability
out of the box.

Consequences that span the repo:

- postal.oaf.org.au is a Linode instance (like cuttlefish/morph, to keep mail reputation isolated from the AWS
  servers) but in ap-southeast (Sydney), and is the first mail server assembled (`terraform/postal/`) **and**
  provisioned (`roles/internal/postal/`) from this repository - cuttlefish/morph provisioning lives in their app
  repos.
- Postal runs via Docker using the official [postalserver/install](https://github.com/postalserver/install)
  helper; the `postal_version` is pinned in the role defaults and upgrades are manual (see
  [docs/POSTAL.md](POSTAL.md)).
- Applications will migrate off cuttlefish one at a time; per-domain SPF/DKIM records move into each service's
  `dns.tf` as they do. Cuttlefish decommissioning, `_spf1.oaf.org.au` cleanup and DMARC tightening
  (#360/#361/#363) are follow-ups tracked on #365.

## 2026-08-10 - Local Ansible testing will move from Vagrant to Docker/Compose

Vagrant + VirtualBox is increasingly poorly supported outside Debian-based Linux (see README "Supported
Platforms"), and full VMs are heavier than needed just to exercise Ansible roles. The plan is to move the local
test target to Docker/Compose containers that are close enough to a real server to be a useful provisioning
target (in the vein of geerlingguy's Ansible test containers), while keeping Vagrant's role of testing the Ansible
setup itself, not application development.

Not yet started: if you find docker-compose config alongside the Vagrantfile, that's this migration in progress,
not stray cruft. Update this entry (or supersede it) once the switch actually happens.
