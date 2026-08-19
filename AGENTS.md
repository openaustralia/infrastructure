# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, GitHub Copilot, and others) when working with code
in this repository. `CLAUDE.md` and `.github/copilot-instructions.md` point here so the guidance lives in one
place.

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

## Contributing

This repo deliberately has **no `CONTRIBUTING.md`, issue template or pull request template of its own**. The
org-wide files in the [`openaustralia/.github`](https://github.com/openaustralia/.github) repo are authoritative
here, and only stop applying if a repo-specific `CONTRIBUTING.md` is ever added. Read them before opening a
branch, PR or issue — `CONTRIBUTING.md`, `PULL_REQUEST_TEMPLATE.md` and `ISSUE_TEMPLATE/`, all under that repo's
`.github/` directory. A local clone may sit alongside your other OAF checkouts (commonly named `.github` or
`dot-github`); check for one first, otherwise read them on GitHub.

The parts that come up most often:

- **Branches** follow [Conventional Branch](https://conventionalbranch.org/#summary):
  `<type>/<issue-number>-<short-description>`, e.g. `feature/123-add-postcode-search`, `bugfix/890-fix-pagination`,
  `doc/7391-clarify-setup-steps`. Branch off `main` — we use GitHub Flow, so `main` is always production-ready.
- **Pull requests** open as drafts, fill in the org PR template, link the related issue, and are assigned to the
  human driving the change. Taking a PR out of draft, once the checks pass, is the author's call.
- **Commits** carry a [DCO](https://developercertificate.org/) `Signed-off-by` trailer (`git commit -s`), added by
  a human — see "Working with AI tools" below for how that interacts with agent-staged commits.
- **AI-assisted work** is disclosed in two places, both naming the specific model: an `Assisted-by:` commit trailer
  and a note in the pull request description.

CI (`.github/workflows/lint.yaml`) runs on every pull request as four separate checks — `make ansible-lint`,
`make yaml-lint`, `make template-check` and `make tf-check-fmt`. `make tf-validate` is *not* run in CI. The
ansible-lint job points `ANSIBLE_CONFIG` at `.github/ansible.cfg` rather than the repo-root `ansible.cfg`, because
vault passphrases aren't available in CI so `vault_identity_list` has to stay unset there — anything you add that
needs to decrypt a vault value will pass locally and fail in CI. `.github/CODEOWNERS` requests reviews from
`@openaustralia/team-infrastructure`.

## Setup (one-time, per operator)

- Needs Python 3.11 (not 3.12+, which breaks Ansible 2.9/2.10 — see `.python-version`). `mise install` sets up
  Ruby/Python/PHP versions.
- Ansible Vault passphrases and AWS/Terraform state creds come from the OAF 1Password account (id in
  `bin/.op-account`; sign in with `op signin --account "$(cat bin/.op-account)"`), fetched via
  `bin/ansible-vault-client`. AWS and Google credentials are your own CLI config, not stored here: `aws login`
  (browser-based, MFA) against the `oaf` profile, with Terraform/Ansible reading through `oaf-legacy`, which
  bridges to that session via `credential_process` — see README "CLI tools for credentials" for the `~/.aws/config`
  setup. `aws sso login`/`aws configure` are no longer recommended (no MFA, long-lived creds on disk). Google via
  `gcloud auth application-default login`.
- `make requirements` — sets up the Python venv, installs ansible-galaxy roles/collections, materialises
  `terraform.pem`, and runs `op-check`/`aws-check`.
- `make aws-check` — fails if the `aws` CLI (2.32.0+, needed for `aws login`) or the Session Manager plugin are
  missing, and bootstraps the `oaf`/`oaf-legacy` profiles in `~/.aws/config` if absent. It only ever writes a
  profile that isn't there, so an existing customised one is left alone; `[profile oaf]`'s `login_session` ARN is
  written as a placeholder you're expected to edit with your own username.
- `make tf-secrets` — renders `terraform/secrets.auto.tfvars` from 1Password (RDS admin password, Cloudflare/Linode
  API tokens) before any `tf-*` target.
- `make setup` — `apt install`s the Ubuntu packages a dev box needs (`parallel`, `jq`, `direnv`). Linux only;
  on macOS install those yourself.
- `make tf-env-check` — non-fatal warning (not a check that fails the build) if `aws sts get-caller-identity` or
  `gcloud auth application-default print-access-token` don't work. It doesn't touch Cloudflare/Linode — those
  tokens come from `make tf-secrets` (1Password), not per-operator credentials.
- If you only have access to some of the four vault IDs (`default`, `all`, `ec2`, `rtk`), set
  `ANSIBLE_VAULT_IDENTITY_LIST` in `.envrc` listing only the ones you can read (see README "Access to everything
  except right to know").

## Common commands

```
make help                              # full list of targets with descriptions
make lint                              # yaml-lint + template-check + ansible-lint + tf-check-fmt + tf-validate
make yaml-lint                         # yamllint on roles/internal/, roles/*.yml and site.yml only
make ansible-lint                      # ansible-lint on roles/internal/, roles/*.yml and site.yml only
make template-check                    # fails if any role's templates/ file doesn't end in .j2

# Ansible provisioning (each does a dry-run "check-*" and a real "apply-*")
make check-<service>                   # dry-run, e.g. check-planningalerts, check-righttoknow
make apply-<service>                   # apply changes, e.g. apply-openaustralia
STAGE=staging make apply-righttoknow   # required for righttoknow (staging/production/all) — no other service uses STAGE
TAGS=foo SKIP_TAGS=bar make apply-X    # limit/skip Ansible tags
ANSIBLE_VERBOSE=vvv make apply-X       # verbose ansible-playbook output
make all                               # run site.yml against every host
make retry                             # re-run site.yml limited to hosts that failed last time
make show-inventory                    # list every host in the EC2 inventory
make show-vars HOST=<host>             # dump all Ansible vars for a host
make show-facts HOST=<host>            # dump all Ansible facts for a host
make show-rds-facts HOST=<host>        # dump the RDS debug facts for a host
make letsencrypt                       # force-renew all registered LetsEncrypt certs

# Terraform (tf-plan/tf-apply/tf-*-target depend on tf-secrets+tf-env-check; tf-validate/tf-check-fmt need neither)
make tf-plan / make tf-apply           # plan/apply the whole terraform/ config
make tf-plan-target MODULE=<module>    # scope to one module, e.g. MODULE=planningalerts
make tf-plan-target RESOURCE=<type>.<name> # scope to one resource, e.g. RESOURCE=aws_db_instance.maindb
make tf-validate                       # tf-check-fmt + terraform validate (no 1Password/AWS access needed)
make tf-init                           # terraform init — ask first, it can migrate state if the backend changed

make scan-<site>                       # linkchecker crawl to log/scan_<site>.html (oaf, openaustralia, planningalerts)
make vagrant                           # install the vagrant plugin/dev certs/requirements needed before `vagrant up`
make clean / make clobber              # clean removes venv/roles/collections; clobber also removes .vagrant/log
```

Local Vagrant boxes (`vagrant up <box>`, `vagrant provision <box>`) are for testing the Ansible setup itself, not
for application development — that happens in each app's own repo/devcontainer. This is planned to move to
Docker/Compose down the track — see `docs/DECISIONS.md`.

Every `apply-*`/`tf-apply*` run — and also `all`, `retry`, `letsencrypt` and `update-github-ssh-keys` — is bracketed
by a `wip-<name>` git tag pushed before the change and replaced by the un-prefixed tag on success (via
`bin/tag-provisioning`) — a lingering `wip-*` tag means that provisioning run failed partway through.

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
  monitoring. `roles/internal/` are OAF-authored roles — one per service (`righttoknow`, `planningalerts`,
  `theyvoteforyou`, `openaustralia`, `metabase`, `proxy`, `openvpn`) plus shared building blocks used across
  several (`base-server`, `mysql`, `postgresql`, `deploy-user`, `oaf.certbot`, `oaf.backup`, `oaf.restic`,
  `cloudflare_realip`, `awscloudwatch`, `rvm.group`) and a few one-way cleanup roles that uninstall a retired
  tool (`remove_mise`, `remove_rbenv`, `remove_rvm`). `roles/external/` are third-party Galaxy roles installed
  by `make requirements`/`make roles` (not linted, since we don't control their layout).
- Inventory and `group_vars/`/`host_vars/` follow standard Ansible layering — most per-service config lives in
  `group_vars/<service>.yml` (e.g. `group_vars/righttoknow.yml`, `group_vars/righttoknow_production.yml`/`_staging.yml`
  for stage overrides). `group_vars/all.yml` holds cross-service defaults (backup settings, `github_users` allowed
  to SSH in, etc.). `inventory/ec2-hosts` is the static inventory in use by the `check-*`/`apply-*` targets, which
  pass it explicitly (`-i ./inventory/ec2-hosts`); `all`, `letsencrypt`, `retry` and `update-github-ssh-keys` pass
  no `-i` and fall back to `ansible.cfg`'s `inventory = inventory` (the whole directory). `inventory/aws_ec2.yml`
  (the dynamic `aws_ec2` plugin inventory, grouping instances by their `Application` tag) already exists but isn't
  wired into any Makefile target yet, and can't actually load today — `amazon.aws` isn't in
  `roles/requirements.yml` (only `community.postgresql` is). It's for a planned future move to dynamic inventory,
  not currently live.

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

### Where the docs live

`README.md` is the entry point (setup, credentials, provisioning, deploying, backups, git tags, mail catching) and
links out to `docs/`. Read the relevant `docs/` file *before* touching a service — they carry the per-service
detail that isn't in the roles:

- `docs/planningalerts.md`, `docs/righttoknow.md`, `docs/theyvoteforyou.md`, `docs/openaustralia.md` — per-service
  setup, deploy and operational notes
- `docs/cloudflare-proxy-migration.md` — what changes when a service moves behind Cloudflare's proxy (orange cloud)
- `docs/DECISIONS.md` — cross-cutting decisions, newest first
- `docs/history.md` — background on how the current setup came to be

### Linting config quirks worth knowing

- `.ansible-lint` skips `meta-incorrect`/`meta-no-info`/`role-name` (not publishing to Galaxy), `var-spacing`
  (cosmetic, cron files), and `yaml` (yamllint already covers it separately); `risky-file-permissions` is a
  warning only, to be fixed incrementally. It also excludes `roles/internal/righttoknow/files/storage.yml` — it
  looks like Ansible YAML but is actually a Rails ERB config template (`<%= Rails.env %>` mixed with YAML
  anchors) copied to the host as a static payload, not something Ansible/ansible-lint can parse.
- `.yamllint` line-length is a 120-char **warning**, not a failure, matching the Rubocop config used by the Ruby
  app repos.

## Working with AI tools

- When a commit message body covers more than one distinct point, use a markdown bullet list rather than one
  flowing paragraph; it's easier to scan and review.
- Check `docs/DECISIONS.md` for past cross-cutting decisions before assuming in an unfamiliar area of the repo; add
  a new entry there (rather than repeating it in multiple places) when a decision spans multiple files/roles/modules
  instead of belonging as a comment in one.
- Default to treating every `make` target as a live-fire production action needing the same explicit, specific,
  right-now go-ahead as a production deploy, however routine the request sounds — **except** the known-safe,
  read-only ones: `help`, `check-*`, `tf-plan*`, `tf-validate`, `tf-check-fmt`, `lint`/`yaml-lint`/`ansible-lint`/
  `template-check`, `show-*`, `op-check`, `aws-check`, `tf-env-check`,
  `venv`/`roles`/`requirements`/`tf-secrets`/`terraform.pem`, `vagrant`/`generate-certificates`, and `scan-*`.
  `tf-init` isn't on that list: `terraform init` can migrate state if the backend config has changed, so ask.
  Everything else — `apply-*`, `tf-apply*`, `tf-apply-target`,
  `letsencrypt`, `all`, `retry`, `update-github-ssh-keys`, and `bin/rotate-vault-passphrase` — changes real
  production infrastructure or who can SSH in, and needs a go-ahead. All of these except
  `bin/rotate-vault-passphrase` are bracketed by the `wip-*` tag described above, so a failed run always leaves a
  marker behind.
- If a `check-*`/`apply-*`/`tf-*` command fails on an auth or credential error, don't guess which credential or
  vault ID is wrong and don't try switching identities to "fix" it — ask. Guessing wrong here risks running
  provisioning against, or with permissions for, the wrong host or environment.
- Never commit a decrypted vault secret, a rendered `terraform/secrets.auto.tfvars`, `terraform.pem`, or any other
  file this repo's `.gitignore`/`make clean` treats as generated-and-local. Use fictional placeholders for
  hostnames, keys, and passwords in examples or docs, per the Australian Privacy Principles.
- Never read/cat a file that plausibly holds live credentials into an AI conversation, even just to check its
  structure — the content ends up in the conversation transcript. That includes `.envrc`/`.env`/`.env.*.local`,
  `set-aws-access-keys.sh`, `terraform.pem`, `terraform/secrets.auto.tfvars`, `terraform/aws.auto.tfvars`,
  `certificates/*.key`/`*.pem` (all gitignored precisely because they carry real secrets), and anything outside
  the repo like `~/.aws/credentials`, SSH private keys, or vault passphrase files. If you need one fact from such
  a file (e.g. which `AWS_PROFILE` is set), `grep` for that specific line rather than printing the whole file.
- Don't rely on this file for the org-wide contributing rules or agent conventions — they change, and a copy here
  would drift. This repo has no `CONTRIBUTING.md` or templates of its own, so the org-level ones govern. Fetch the
  current versions before opening a PR or an issue:

  `curl -fsSL https://raw.githubusercontent.com/openaustralia/.github/main/.github/CONTRIBUTING.md`

  `curl -fsSL https://raw.githubusercontent.com/openaustralia/.github/main/AGENTS.md`

  Any equivalent fetch of those URLs works (web fetch, or `gh api` if the GitHub CLI is installed); don't assume a
  particular tool is present. A local clone may sit beside your other OAF checkouts under a name like `.github` or
  `dot-github`; check for one first, but don't assume it's present or up to date. The PR and issue templates are org-level too, under
  `.github/PULL_REQUEST_TEMPLATE.md` and `.github/ISSUE_TEMPLATE/` in that repo. Between them they cover branch
  naming, draft PRs and assignees, DCO sign-off, AI disclosure, staging commits rather than making them,
  standing-approval and allow-pattern scoping, issue drafting, word-wrapping in PR/issue bodies, and
  credential/privacy handling — so none of that is restated here.
