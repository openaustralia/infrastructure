---
status: accepted
date: 2026-08-21
---

# Ansible upgrades in two stages, landing on ansible-core 2.19 first

Ansible 2.10 could not manage any host running Python 3.12 or newer, which made Ubuntu 24.04 - the only
migration target with long support left - unreachable (#574). The fix is to upgrade the Ansible toolchain, but
the choice of landing version is constrained from both ends by the fleet's oldest hosts:

- `au.proxy` (Ubuntu 16.04, Python 3.5) is below every current ansible-core's target floor. It has been out of
  Ubuntu support for five years and is being rebuilt anyway (#528), so this upgrade deliberately leaves it
  unmanageable by Ansible until that rebuild.
- `theyvoteforyou` (Ubuntu 20.04, Python 3.8) sits exactly on ansible-core 2.19's target floor. Core 2.20
  raised the floor to Python 3.9, so anything newer than 2.19 would freeze theyvoteforyou too - blocking active
  Ansible work on a production service, which we weren't willing to do.

So the upgrade is staged:

1. **Now**: land the `ansible` community package 12.x (ansible-core 2.19). Every host except `au.proxy` stays
   manageable, and 24.04 targets are unblocked. Core 2.19 is end-of-life upstream on 2026-11-30, so this is
   knowingly short-lived.
2. **After theyvoteforyou moves to 24.04**: bump to the current `ansible` package. That later bump is small
   because this stage crossed the hard 2.10 chasm once (FQCN, collection relocations, removed syntax,
   ansible-lint config). It also makes 26.04 (Python 3.14) an officially supported target, which the
   Vagrantfile's mysql/postgresql box upgrade waits on.

Two related packaging choices, made for a low-maintenance setup: we install the `ansible` community bundle
rather than bare `ansible-core` plus hand-pinned collections (the bundle's collections are curated and
version-matched, so `roles/requirements.yml` no longer pins any collections), and the venv is created with
Python's stdlib `venv` instead of the external `virtualenv` package.

## Consequences

- `au.proxy` cannot be provisioned until it is rebuilt on a modern Ubuntu (#528). If it needs an emergency
  config change before then, it's a manual job.
- Running a just-EOL'd ansible-core after 2026-11-30 is accepted as the cost of keeping theyvoteforyou
  manageable. The follow-up bump is tracked as its own issue and gates on theyvoteforyou leaving 20.04 - don't
  leave it open-ended.
- Stale collections installed under `~/.ansible/collections` or the repo's `collections/` dir from the
  pre-bundle setup shadow the bundled copies and break module resolution. `make roles` clears the repo-local
  dir, `ansible.cfg` points the search path away from the operator-level one, and the ansible-lint Makefile
  target pins `ANSIBLE_HOME` for the same reason.
