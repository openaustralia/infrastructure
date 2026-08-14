# Decisions

Cross-cutting engineering decisions and directives that aren't tied to one file or area, so a comment alone
wouldn't surface them. A decision local to one file/role/module belongs as a comment there instead, explaining why.

Append new entries at the top. Don't edit past entries except to mark them superseded (and say by what).

## 2026-08-14 - Sentry DSNs ship to apps as env vars, starting with Right to Know

Issue #536 added Sentry credentials to `group_vars` for every service (`sentry_host` in `all.yml`, per-service
`sentry_project_id`, per-stage `sentry_secret_key` for Right to Know), composed into `sentry_dsn`, but nothing
consumed them. Right to Know is the first consumer: `roles/internal/righttoknow/templates/rails_env.rb.j2`
renders `SENTRY_DSN` and `SENTRY_ENVIRONMENT` into `shared/rails_env.rb`, which Alaveteli loads from
`config/boot.rb` - one file that reaches Passenger, sidekiq, the init.d daemons and cron alike, with no
`SHARED_FILES` change. Points to hold onto if wiring up the other services:

- Key the Sentry environment off the Ansible stage/group, never `RAILS_ENV` - both Right to Know stages run
  `RAILS_ENV=production`, which is exactly why there are two `sentry_secret_key`s.
- Fail loudly (an `assert`, per the Stripe webhook precedent) rather than rendering a DSN with an empty part,
  which would silently disable reporting.
- The SDK side lives in the app's own repo (for Right to Know, the theme's `lib/sentry_init.rb` - see that
  repo's `docs/DECISIONS.md`). The existing exception notification emails stay on alongside Sentry for now.

## 2026-08-10 - Local Ansible testing will move from Vagrant to Docker/Compose

Vagrant + VirtualBox is increasingly poorly supported outside Debian-based Linux (see README "Supported
Platforms"), and full VMs are heavier than needed just to exercise Ansible roles. The plan is to move the local
test target to Docker/Compose containers that are close enough to a real server to be a useful provisioning
target (in the vein of geerlingguy's Ansible test containers), while keeping Vagrant's role of testing the Ansible
setup itself, not application development.

Not yet started: if you find docker-compose config alongside the Vagrantfile, that's this migration in progress,
not stray cruft. Update this entry (or supersede it) once the switch actually happens.
