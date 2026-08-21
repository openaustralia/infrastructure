---
status: accepted
date: 2026-08-11
---

# Cuttlefish is being replaced by Postal, provisioned from this repo

Cuttlefish uses oaf.org.au as the Return-Path for every sending domain, which breaks DMARC alignment for
planningalerts.org.au and morph.io and blocks moving any of our DMARC policies past `p=none`
([#365](https://github.com/openaustralia/infrastructure/issues/365)). Rather than upgrade cuttlefish (barely
maintained, needs a software upgrade just to fix the Return-Path), we're migrating to
[Postal](https://github.com/postalserver/postal), which handles per-domain return paths, DKIM and deliverability
out of the box.

## Consequences

Consequences that span the repo:

- postal.oaf.org.au is a Linode host (like cuttlefish/morph, to keep mail reputation isolated from the AWS hosts)
  but in ap-southeast (Sydney), and is the first mail service assembled (`terraform/postal/`) **and** provisioned
  (`roles/internal/postal/`) from this repository - cuttlefish/morph provisioning lives in their app repos.
- Postal runs via Docker using the official [postalserver/install](https://github.com/postalserver/install)
  helper; the `postal_version` is pinned in the role defaults and upgrades are manual (see
  [docs/POSTAL.md](../POSTAL.md)).
- Applications will migrate off cuttlefish one at a time; per-domain SPF/DKIM records move into each service's
  `dns.tf` as they do. Cuttlefish decommissioning, `_spf1.oaf.org.au` cleanup and DMARC tightening
  (#360/#361/#363) are follow-ups tracked on #365.
