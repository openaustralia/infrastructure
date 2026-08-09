# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Terraform + Ansible configuration that provisions and configures almost all of OpenAustralia Foundation's
servers (AWS EC2, plus a couple of Linode VMs for cuttlefish and morph.io). This repo does **not** deploy
application code — each application (PlanningAlerts, They Vote For You, Right to Know / Alaveteli, OpenAustralia)
lives in its own repository and is deployed from there with Capistrano. Terminology used throughout the repo and
docs:

- **assembling** *(suggested, for consistency — not yet in wide use)* — using Terraform to create/update the
  infrastructure a server needs (EC2 instances, RDS databases, DNS, load balancers, etc.), before Ansible ever
  touches the server
- **provisioning** — configuring a server with Ansible (installing packages, users, cron jobs, SSL certs, etc.)
- **deployment** — installing/updating the actual web application with Capistrano, done from the app's own repo

Small, low-capacity charity team — favour simple, low-maintenance solutions over ones that need ongoing attention.

This repo is worked on via terminal Claude Code and other editors alike — keep guidance and commands in this file
tool-agnostic (plain shell/`make` commands, not editor-specific steps), both when following it and when adding to
it.

## Setup (one-time, per operator)

- Needs Python 3.11 (not 3.12+, which breaks Ansible 2.9/2.10 — see `.python-version`). `mise install` sets up
  Ruby/Python/PHP versions.
- Ansible Vault passphrases and AWS/Terraform state creds come from the OAF 1Password account (`op signin --account
  oaforgau`), fetched via `bin/ansible-vault-client`. AWS and Google credentials are your own CLI config (`aws
  configure`, `gcloud auth application-default login`), not stored here.
- `make requirements` — sets up the Python venv, installs ansible-galaxy roles/collections, checks 1Password.
- `make tf-secrets` — renders `terraform/secrets.auto.tfvars` from 1Password (RDS admin password, Cloudflare/Linode
  API tokens) before any `tf-*` target.
- `make tf-env-check` — verifies AWS/Cloudflare/Linode/gcloud credentials are reachable.
- If you only have access to some of the four vault IDs (`default`, `all`, `ec2`, `rtk`), set
  `ANSIBLE_VAULT_IDENTITY_LIST` in `.envrc` listing only the ones you can read (see README "Access to everything
  except right to know").

## Common commands

```
make help                              # full list of targets with descriptions
make lint                              # yaml-lint + template-check + ansible-lint + tf-check-fmt + tf-validate
make yaml-lint                         # yamllint on roles/ and site.yml only
make ansible-lint                      # ansible-lint on roles/ and site.yml only
make template-check                    # fails if any role's templates/ file doesn't end in .j2

# Ansible provisioning (each does a dry-run "check-*" and a real "apply-*")
make check-<service>                   # dry-run, e.g. check-planningalerts, check-righttoknow
make apply-<service>                   # apply changes, e.g. apply-openaustralia
STAGE=staging make apply-righttoknow   # scope to a stage/host group (righttoknow, openaustralia support this)
TAGS=foo SKIP_TAGS=bar make apply-X    # limit/skip Ansible tags
ANSIBLE_VERBOSE=vvv make apply-X       # verbose ansible-playbook output
make all                               # run site.yml against every host
make retry                             # re-run site.yml limited to hosts that failed last time
make show-vars HOST=<host>             # dump all Ansible vars for a host
make show-facts HOST=<host>            # dump all Ansible facts for a host
make letsencrypt                       # force-renew all registered LetsEncrypt certs

# Terraform (always run tf-secrets/tf-env-check first — the tf-* targets depend on them)
make tf-plan / make tf-apply           # plan/apply the whole terraform/ config
make tf-plan-target TARGET=<module>    # scope to one module, e.g. TARGET=planningalerts
make tf-validate                       # tf-check-fmt + terraform validate

make vagrant                           # bring up local Vagrant VMs for testing Ansible roles (not app dev)
make clean / make clobber              # clean removes venv/roles/collections; clobber also removes .vagrant/log
```

Local Vagrant boxes (`vagrant up <box>`, `vagrant provision <box>`) are for testing the Ansible setup itself, not
for application development — that happens in each app's own repo/devcontainer. This is planned to move to
Docker/Compose down the track — see `docs/DECISIONS.md`.

Every `apply-*`/`tf-apply*` run is bracketed by a `wip-<name>` git tag pushed before the change and replaced by the
un-prefixed tag on success (via `bin/tag-provisioning`) — a lingering `wip-*` tag means that provisioning run failed
partway through.

## Architecture

### Two-layer split: Terraform then Ansible

- **`terraform/`** creates infrastructure: EC2 instances, RDS databases, DNS (Cloudflare), load balancers, S3
  buckets, IAM. Organised as one subdirectory/module per service (`terraform/planningalerts/`,
  `terraform/righttoknow/`, `terraform/theyvoteforyou/`, `terraform/oaf/`, `terraform/morph/`, `terraform/cuttlefish/`,
  etc.), wired together in `terraform/main.tf`. State lives in the `oaf-terraform-state` S3 bucket
  (`terraform/backend.tf`). PlanningAlerts supports blue/green EC2 fleets driven from Terraform for zero-downtime
  major upgrades (e.g. Ruby version bumps); everyday deploys still go through Capistrano.
- **Ansible** (`site.yml`, `roles/`, `group_vars/`, `host_vars/`, `inventory/`) configures the OS and services on
  top of instances Terraform created: packages, users, MySQL/PostgreSQL, nginx/Apache + certbot, cron, backups,
  monitoring. `roles/internal/` are OAF-authored roles (one per service, e.g. `righttoknow`, `planningalerts`,
  `theyvoteforyou`, `mysql`, `base-server`, `oaf.certbot`, `oaf.backup`); `roles/external/` are third-party
  Galaxy roles installed by `make requirements`/`make roles` (not linted, since we don't control their layout).
- Inventory and `group_vars/`/`host_vars/` follow standard Ansible layering — most per-service config lives in
  `group_vars/<service>.yml` (e.g. `group_vars/righttoknow.yml`, `group_vars/righttoknow_production.yml`/`_staging.yml`
  for stage overrides). `group_vars/all.yml` holds cross-service defaults (backup settings, `github_users` allowed
  to SSH in, etc.). `inventory/ec2-hosts` is the static inventory actually in use — every Makefile target passes it
  explicitly (`-i ./inventory/ec2-hosts`). `inventory/aws_ec2.yml` (the dynamic `aws_ec2` plugin inventory, grouping
  instances by their `Application` tag) already exists but isn't wired into any Makefile target yet — it's for a
  planned future move to dynamic inventory, not currently live.

### Secrets: Ansible Vault with 4 vault IDs

Encrypted values in `group_vars`/`host_vars` are tagged with one of four vault IDs — `default` (legacy catch-all),
`ec2` (AWS/RDS secrets used by everything on EC2), `all` (cross-service defaults like certbot/backups), `rtk`
(Right to Know only). Passphrases for all four are fetched from the **DevOps** 1Password vault by
`bin/ansible-vault-client`, dispatched via `vault_identity_list` in `ansible.cfg`. Rotate a passphrase with
`bin/rotate-vault-passphrase <vault-id>` — it re-encrypts every `!vault` block tagged with that ID; only those
blocks should change in the resulting diff.

### Templates must be `.j2`

Every Ansible `template:` source **must** end in `.j2` (`nginx.conf.j2`, `database.yml.j2`), keeping it visually
distinct and out of the YAML/JSON linters. If a file has no Jinja2 (`{{ }}`/`{% %}`), it's not a template — put it
in the role's `files/` directory and use `copy:` instead. `make template-check` enforces this in CI for
`roles/internal/*/templates/` (not `roles/external/`).

### Deployment split by app

Each application repo drives its own Capistrano deploy against servers this repo provisions:
PlanningAlerts (`planningalerts-app`), They Vote For You (`publicwhip`), Right to Know (`alaveteli`, now upstream —
see its own README), OpenAustralia. See README.md "Deploying" section for the exact `cap` invocations per app and
stage (`development`/`staging`/`production`).

### Linting config quirks worth knowing

- `.ansible-lint` skips `meta-incorrect`/`meta-no-info`/`role-name` (not publishing to Galaxy), `var-spacing`
  (cosmetic, cron files), and `yaml` (yamllint already covers it separately); `risky-file-permissions` is a
  warning only, to be fixed incrementally.
- `.yamllint` line-length is a 120-char **warning**, not a failure, matching the Rubocop config used by the Ruby
  app repos.

## Working with AI tools

- If something here doesn't match what you're consistently seeing in the repo, flag the mismatch and ask which
  needs fixing (so it's fixed once and for all), presenting fixing the code/config as the easy default choice and
  updating this file as the alternative.
- When a commit message body covers more than one distinct point, use a markdown bullet list rather than one
  flowing paragraph; it's easier to scan and review.
- Check `docs/DECISIONS.md` for past cross-cutting decisions before assuming in an unfamiliar area of the repo; add
  a new entry there (rather than repeating it in multiple places) when a decision spans multiple files/roles/modules
  instead of belonging as a comment in one.
- `apply-*`, `tf-apply*`, `tf-apply-target`, `letsencrypt`, and `bin/rotate-vault-passphrase` change real production
  infrastructure (DNS, EC2/RDS, live certs, vault passphrases everyone relies on) — treat every one of these as a
  live-fire action needing the same explicit, specific, right-now go-ahead as a production deploy, however routine
  the request sounds. `check-*`/`tf-plan*` (dry-run) are always safe to run to see what a corresponding apply would do.
- If a `check-*`/`apply-*`/`tf-*` command fails on an auth or credential error, don't guess which credential or
  vault ID is wrong and don't try switching identities to "fix" it — ask. Guessing wrong here risks running
  provisioning against, or with permissions for, the wrong host or environment.
- Never commit a decrypted vault secret, a rendered `terraform/secrets.auto.tfvars`, `terraform.pem`, or any other
  file this repo's `.gitignore`/`make clean` treats as generated-and-local. Use fictional placeholders for
  hostnames, keys, and passwords in examples or docs, per the Australian Privacy Principles.
- Stage commits, don't make them — `git add` the files, then write the proposed message (with the `Assisted-by:`
  trailer) to `.git/GITGUI_MSG` (used by `git gui`) and display it for copy/paste into an IDE. Check the file first;
  if it already has content, ask before overwriting rather than clobbering an existing draft. This keeps review and
  sign-off a deliberate separate human act, not a rubber stamp.
- Check the `openaustralia/.github` repo (a local clone may exist at `../.github` — check there first, but don't
  assume it's present) for the org-wide PR/issue templates and `CONTRIBUTING.md`.
- PRs must disclose material AI involvement per OAF's CLA (`openaustralia/.github` repo, `CLA/CLA.md`): a note in
  the PR description, distinct from the commit `Assisted-by:` trailer.
- PRs I create must be opened as drafts (`gh pr create --draft --assignee <human>`), never ready-for-review
  directly, and assigned to the human driving the change, not me (per CONTRIBUTING.md; no `Signed-off-by`/
  `Co-authored-by` trailer for AI either). Taking a PR out of draft is the human's call.
- GitHub issues have no draft state. Don't create one directly — draft the title/body for the human to file
  themselves, unless they've explicitly asked you to create it this time.
