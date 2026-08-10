# Decisions

Cross-cutting engineering decisions and directives that aren't tied to one file or area, so a comment alone
wouldn't surface them. A decision local to one file/role/module belongs as a comment there instead, explaining why.

Append new entries at the top. Don't edit past entries except to mark them superseded (and say by what).

## 2026-08-10 - Local Ansible testing will move from Vagrant to Docker/Compose

Vagrant + VirtualBox is increasingly poorly supported outside Debian-based Linux (see README "Supported
Platforms"), and full VMs are heavier than needed just to exercise Ansible roles. The plan is to move the local
test target to Docker/Compose containers that are close enough to a real server to be a useful provisioning
target (in the vein of geerlingguy's Ansible test containers), while keeping Vagrant's role of testing the Ansible
setup itself, not application development.

Not yet started: if you find docker-compose config alongside the Vagrantfile, that's this migration in progress,
not stray cruft. Update this entry (or supersede it) once the switch actually happens.
