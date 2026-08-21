# Development hosts: testing Ansible on Linux and macOS

**This is a proposal for discussion, not an agreed plan.** Suggested edits on the draft pull request are the point
of it.

**Goal:** let both Linux on `x86_64` and macOS on `arm64` test the Ansible playbooks in this repository.

**Status:** nothing started. `Vagrantfile` still works on Linux `x86_64` and stays until a service is proven on the
new path, so nobody loses a working setup while this is discussed.

This document has two halves. The first is the proposal, structured as four decisions that can be taken
independently. The second, after the horizontal rule near the end, is a **proposed replacement for
[`docs/adr/0001`](adr/0001-local-ansible-testing-moves-to-docker.md)**, sitting here rather than in `docs/adr/` so
it can be argued over a line at a time before the real ADR is touched.

## Why this is needed

Vagrant + VirtualBox does not work on Apple Silicon, so a contributor on a current Mac cannot test an Ansible
change at all. `README.md` "Supported Platforms" already concedes that "the only platform that we know works is
debian-based Linux systems".

There is also a second, unrelated reason Vagrant is a dead end: Canonical stopped publishing Vagrant boxes from
Ubuntu 24.04 onward, citing Vagrant's move to the Business Source Licence. There will never be an official
`ubuntu/noble64`, so even on Linux the current approach cannot follow us forward.

## What is being proposed

One Compose project with two kinds of container:

- **`control`**, where `ansible-playbook` and `terraform` run. This is the devcontainer proper.
- **development hosts**, one per service, running systemd and sshd so Ansible reaches them over real SSH and
  Capistrano can deploy to them the way it does to a live host.

You choose which hosts to start with `DEV_HOSTS`, and `DEV_BACKEND` chooses whether they are local containers or
rented cloud hosts. Both look identical to `make check-<service>`. The mechanics are in
[how host selection works](#reference-how-host-selection-and-the-containers-work) if you want them now, but no
decision below depends on reading that first.

## Four decisions, taken independently

Each section below is self-contained: what you get, what it costs, and what it does not give you. They stack, but
any one can be taken on its own.

| | You gain | It costs | Blocked on |
|---|---|---|---|
| [EASY](#easy-three-services-on-both-architectures) | theyvoteforyou, righttoknow, planningalerts | build time only, no money | nothing |
| [MEDIUM](#medium-three-more-services-after-two-decisions) | metabase, proxy, openaustralia as well | build time, plus two decisions | Xapian pin, xenial |
| [HARD](#hard-cloud-hosts-and-kernel-level-boot-testing) | morph and postal, plus kernel-level boot testing | about A$1.52 per fleet-day | provider choice, spend sign-off |
| [LOW MEMORY](#low-memory-testing-without-22gb-of-ram) | any service on an 8GB machine | nothing, or the same as HARD | which option you pick |

## EASY: three services on both architectures

**If we do this, a developer on macOS Apple Silicon or Linux x86_64 can run `make check-theyvoteforyou`,
`make check-righttoknow` and `make check-planningalerts`, natively, for free, with no cloud account.** That is
three of the eight services, plus the MySQL, PostgreSQL and Redis stand-ins they depend on.

These three were verified as having a complete arm64 path: Passenger for jammy, nginx, memcached, Varnish,
wkhtmltopdf, pdftk-java and Ubuntu's xapian-tools all publish arm64. Ruby is a non-issue, because RVM has no
prebuilt binary for `ruby-3.4.4` or `ruby-3.3.4` on *either* architecture, so it already compiles from source on
amd64 today.

### What it needs

**Fix our own amd64 pins.** Seven places hardcode amd64 where the vendor does publish arm64. Each is a one-line
change; `sentry-cli` and `restic` also need a fresh sha256. Only the first four matter for the three services
above, but they are cheap enough to do together, and anything still broken afterwards moves to a later stage.

| Service | Location | Pin |
|---|---|---|
| theyvoteforyou | `roles/internal/theyvoteforyou/tasks/main.yml:326` | `deb [arch=amd64]` Chrome |
| righttoknow | `roles/internal/righttoknow/tasks/main.yml:602-608` | `sentry-linux-x64` |
| all services | `roles/internal/oaf.restic/tasks/install.yml:24-25` | `linux_amd64` |
| all services | `roles/internal/awscloudwatch/tasks/main.yml:15-16` | `ubuntu/amd64/`, EC2-gated so moot |
| metabase | `roles/internal/metabase/tasks/main.yml:12` | `deb [arch=amd64]` Docker, and `jammy` hardcoded |
| postal | `roles/internal/postal/tasks/main.yml:19-29` | `[arch=amd64]` Docker |
| morph | `morph/provisioning/roles/docker-server-linode/tasks/main.yml:19` | `[arch=amd64]` |

**Build the target image, the compose project and the inventory.** See
[how host selection works](#reference-how-host-selection-and-the-containers-work). The short version: layer
`openssh-server` onto `geerlingguy/docker-ubuntu2404-ansible`, which is already multi-arch, and drive host
selection from the Makefile.

**Supply vault fixtures.** Extend the pattern already in `group_vars/development.yml` and
`host_vars/righttoknow.test.yml` so every encrypted variable these services touch has a development value. Without
this a contributor with no vault passphrase still cannot run anything, which is what issue #96 has been open about
since 2018.

### What it does not give you

- **Kernel-level boot testing.** Userspace boot *is* testable here: `docker compose stop` then `start` keeps the
  container and its filesystem and restarts systemd, which re-reads `multi-user.target.wants/` and starts whatever
  is enabled, in dependency order. So "did Ansible actually `systemctl enable` this, and does it come up on its
  own?" is answerable locally. What is not is anything below systemd: kernel and initramfs, `/etc/fstab` and mount
  units against real block devices, namespaced or read-only `sysctl` settings, cloud-init, units gated on
  `ConditionVirtualization`, a role that triggers a reboot handler, and above all "does the host actually come
  back", which is the failure a reboot test exists to catch. See
  [HARD](#hard-cloud-hosts-and-kernel-level-boot-testing).
  Note `docker compose down` then `up` is **not** the equivalent of a reboot: it destroys the container and builds
  a new one from the image, discarding everything Ansible did unless it is on a named volume. That tests
  provisioning from scratch, not restart behaviour.
- **Browser-driven tests inside the host.** `chromedriver` has no stable linux-arm64 build and Ubuntu has no arm64
  `chromium-driver`.
- **The swap role.** `geerlingguy.swap` only runs where `swap_file_size_mb` is defined, which is planningalerts and
  openaustralia. Leaving it undefined for development hosts skips it, so that role goes untested locally.

## MEDIUM: three more services, after two decisions

**If we also do this, add `make check-metabase`, `make check-proxy` and `make check-openaustralia`, taking it to
six of the eight services, still local and still free.** The work is small; the reason this is not EASY is that
two of the three need a decision first, and one needs something tested that nobody has tested.

### metabase: needs a smoke test, not a decision

metabase installs Docker and runs a container, so its development host needs Docker inside it. The image itself is
multi-arch, so the architecture is fine. The unknown is that nested Docker *plus* systemd in one container has no
authoritative guidance on the cgroup namespace setting. It needs trying rather than assuming. It also needs
dedicated volumes for both `/var/lib/docker` and `/var/lib/containerd`.

While in there: metabase still uses pip-installed Compose v1 and the deprecated `docker_compose` module, worth
modernising.

### proxy: needs a decision about xenial

proxy is the only host still on Ubuntu 16.04, and xenial is now unsupportable on *both* backends.
`geerlingguy/docker-ubuntu1604-ansible` is amd64-only and frozen since 2021, and the cheapest cloud option's
oldest Ubuntu is 20.04. Since 16.04 left standard support in 2021, moving proxy to a supported release is the
cheaper fix than building our own xenial base image. tinyproxy is compiled from source, so the architecture itself
was never the problem.

### openaustralia: needs a decision about the Xapian pin

`ppa:xapian/backports` publishes no arm64 build of the `libxapian-dev 1.4.22` that openaustralia pins. Its jammy
arm64 index carries only architecture-independent packages; the amd64 index carries the real ones. Ubuntu's own
arm64 build is 1.4.18.

The pin is deliberate. `group_vars/openaustralia.yml` keeps `libxapian-dev` in lockstep with the bindings tarball
compiled at `roles/internal/openaustralia/tasks/main.yml:283-315`, and that build is guarded by a version-keyed
stamp file, so a fresh arm64 host will always attempt it. Three ways out:

1. Build libxapian from source alongside the bindings the role already compiles. Preferred, since the machinery is
   already there.
2. Relax the pin to Ubuntu's arm64 1.4.18 and rebuild the bindings to match. This is an ABI decision, not a config
   tweak.
3. Do neither, and openaustralia moves to [HARD](#hard-cloud-hosts-and-kernel-level-boot-testing).

openaustralia also has `swap_file_size_mb` set, so it shares planningalerts' skipped swap role.

## HARD: cloud hosts, and kernel-level boot testing

**If we also do this, every service is testable, including morph and postal, and the boot behaviour that
containers cannot reach becomes testable for all of them.** This is the only option that buys the last two
services, and the only one that can answer whether a host actually comes back after a reboot. It costs real money,
though not much: about A$0.16 for three hosts for an afternoon and about A$1.52 for the whole fleet for a working
day.

The model is deliberately blunt: **AWS and Linode are OAF live infrastructure, and a separate provider is
development.** A separate provider means a separate bill, no chance of confusing a development host with a live
one, and the freedom to destroy everything in the development account without a second thought.

### Why containers cannot do this

Three independent reasons, any one sufficient:

**morph and postal have no arm64 path.** `ghcr.io/postalserver/postal:3.3.7` is a single-platform amd64 image.
Every `openaustralia/buildstep` tag is amd64, and morph routes all scraper traffic through the amd64-only
`openaustralia/morph-mitmdump`.

**Docker-in-Docker cannot be combined with emulation.** Both need a Docker daemon inside the host, and the
devcontainers docker-in-docker guidance states plainly that this will not work with an emulated x86 image on
Docker Desktop on an Apple Silicon Mac, because host and container must share a chip architecture. On Linux
`x86_64` both work as containers; it is only Apple Silicon that forces the cloud.

**Containers reboot only as far as userspace.** `docker compose stop` then `start`, or `docker restart`, keeps the
container and its filesystem and restarts systemd, which boots into its default target and starts whatever is
enabled in `multi-user.target.wants/`. So the routine question, "did Ansible actually `systemctl enable` this and
does it come up on its own", is answerable on a container. What is not is anything below systemd: kernel and
initramfs, `/etc/fstab` and mount units against real block devices, `sysctl` settings that are namespaced or
read-only in a container, cloud-init, units gated on `ConditionVirtualization`, a role that triggers a reboot
handler, unattended-upgrades' automatic reboot, and above all whether the host actually comes back, which is the
failure a reboot test exists to catch. A broken fstab entry that would hang a real server is simply inert in a
container.

This is a partial capability gap, so it is a weaker reason for the cloud backend than the two above. It matters
for the roles that manage mounts, swap and kernel settings, and not much for the rest.

morph is a deeper case than postal and is provisioned from its own repository. Its `discourse` role hard-fails
under 2048 MB and its Vagrant box is 8GB, so size for the 8GB tier. Its provisioning still targets xenial, which
needs bumping regardless of backend.

### Hosts expire unless you ask for more

Cloud hosts are created with an expiry and the default is that they die; extending is a deliberate act. This is
preferred over a central reaper because it **fails safe**: a sweeper that breaks leaves everything running and
billing, whereas an expiry that breaks still leaves the host expiring.

One detail decides how it is built. Billing runs from creation until the host is *cancelled*, and cancelling is a
separate action from powering off, so **a host shutting itself down does not stop the bill.** Expiry has to call
the provider API. That leaves a trade-off: a self-cancelling host needs an API token on a disposable box, and if
the provider cannot issue a delete-only token that token can create hosts too; halting locally and cancelling from
a scheduled job on OAF's own token avoids the credential but makes the money depend on a central job, so it fails
open.

AWS was considered for this and rejected. `InstanceInitiatedShutdownBehavior=terminate` would give self-destruct
with no credential and no sweeper, but AWS documents it as firing on "a command such as **shutdown** or
**poweroff**" and does not mention reboot. Since a failed reboot is exactly what reboot testing exists to catch,
an arrangement where it destroys the host and its evidence is the wrong way round.

### What it costs, and what it does not protect you from

Prices read 2026-08-20, inc GST: 2GB A$10.78/month, 4GB A$21.56, 8GB A$43.12, prorated hourly. Ordinary use is
negligible; the entire risk is forgotten hosts, where a month costs about A$150, roughly ninety days of correct
use.

Two findings make expiry a human control rather than a technical one:

- **No provider surveyed offers a hard spending cap**, only alerts. DigitalOcean's documentation says outright
  that a billing threshold "is not a spending cap and does not limit how much you can use".
- **No provider offers instance TTL or auto-destroy**, which is why expiry is ours to build and maintain.

### Which provider is still open

BinaryLane is Australian, cheap, and fits the model cleanly, but its Terraform provider is community tier where
every alternative surveyed is partner tier, and whether it can issue scoped API tokens is unconfirmed.
DigitalOcean has a Sydney region, per-second billing better suited to iterate-and-destroy loops, and the most
granular token scopes of the five surveyed. This needs deciding, and recurring spend needs sign-off separately
from the technical direction.

## LOW MEMORY: testing without 22GB of RAM

**If we do this, a contributor on an 8GB machine can test any service, rather than being unable to run the
fleet.** All eleven hosts at the current Vagrant sizing of 2GB each is about 22GB, so the 16GB machine already
cannot run the full set today, and an 8GB machine is well short.

This is a genuinely separate decision from the three above, because it has two possible answers at very different
prices:

1. **Subset selection only, free.** `DEV_HOSTS` already means you start one, some or all, so most work needs two
   or three hosts rather than eleven. This is included in [EASY](#easy-three-services-on-both-architectures)
   at no extra cost, and for most tasks it is sufficient on its own.
2. **Run the hosts in the cloud, same mechanism as [HARD](#hard-cloud-hosts-and-kernel-level-boot-testing).**
   Nothing runs locally, so local memory stops mattering entirely. This is what makes an 8GB machine a
   first-class development environment rather than a compromise, and it is why the cloud backend is worth having
   even for contributors who are not on Apple Silicon.

Worth deciding explicitly rather than by accident, because option 1 costs nothing and covers most days, while
option 2 is what you need on the day you want the whole fleet at once.

## Reference: how host selection and the containers work

**Host selection.** Give each development host service its own `profiles:` in the tracked compose file, authored
once. The `control` service gets no `profiles:` key so it always starts, and must not be given one, since a
profiled dev service breaks the devcontainer build step. Then an untracked `dev-hosts.mk`, copied from a tracked
`dev-hosts.mk-example`:

```make
DEV_HOSTS += theyvoteforyou
DEV_HOSTS += righttoknow
#DEV_HOSTS += planningalerts
```

The Makefile does `-include dev-hosts.mk` and turns it into `COMPOSE_PROFILES`. A command-line assignment beats
the included file, so `make dev-up DEV_HOSTS=theyvoteforyou` works for one-offs. Needs one `.gitignore` line.

**Do not** try `"runServices": ["${localEnv:DEV_HOSTS}"]`. Verified from the devcontainer CLI source that
substitution is a string replace inside each array element, so `a,b` becomes one element and compose rejects it.
The CLI has no `--profile` or compose-argument passthrough, and `devcontainers/cli#669`, asking it to honour
`COMPOSE_PROFILES`, is open with its fix unmerged.

**Dependencies across profiles are a hard error**, not a silent skip: compose returns `no such service`. A
dependency with no profile is pulled in fine. Since a service may hold several profiles, give the database
stand-ins the union of their consumers, so `postgresql` carries `[righttoknow, planningalerts, metabase]` and
`mysql` carries `[theyvoteforyou, openaustralia]`. Then uncommenting one host brings up exactly the database it
needs.

**Target image.** No maintained Ubuntu image with systemd *and* sshd for Ansible exists.
`geerlingguy/docker-ubuntu2204-ansible` and `-ubuntu2404-ansible` ship systemd but no `openssh-server`, being
built for Ansible's `docker` connection plugin. Both are multi-arch, so layer `openssh-server` on top and
re-enable `ssh`. They need `privileged: true`, `cgroup: host` and a `/sys/fs/cgroup` bind mount, so they are more
privileged than a Vagrant VM was.

**Reachability.** The `control` container reaches hosts by compose service name on port 22 with no published
ports, which is why Ansible runs there. Capistrano runs from an application repo on the host, so any host it
deploys to must publish SSH on a loopback port. On Linux container IPs are reachable from the host and on macOS
they are not, so anything tested only on Linux will appear to work and then not port.

**`deploy-user` needs care.** It applies `authorized_key` with `exclusive: true` over `deploy`, `ubuntu` and
`root`, needs `terraform.pem` on the control node, and needs outbound HTTPS to `github.com/<user>.keys` from the
host. Ubuntu 24.04 provides an `ubuntu` user; earlier releases do not.

## Reference: order of work

**Phase 0, prove it.** One jammy host, Ansible reaches it from `control`, `make check-theyvoteforyou` runs.
Confirm `deploy-user` survives.

**Phase 1, theyvoteforyou end to end.** Add `inventory/dev/executable`, generating hosts from `docker compose ps`
and later from the cloud provider. Rewrite `group_vars/development.yml`, whose hardcoded `192.168.56.10` and `.11`
are the single most affected lines. Add the Makefile targets. Keep `certificates/generate-certificates.sh`, since
the `development` group conditionals in `righttoknow/tasks/certificates.yml`, `theyvoteforyou/tasks/main.yml` and
`openaustralia/tasks/main.yml` install those self-signed certs in place of certbot; note it currently moves
`morph.test.*` into the sibling morph checkout, flagged `FIXME`. Then confirm a Capistrano deploy from the
`theyvoteforyou` repo reaches the host.

**Phase 2, the rest of EASY, then MEDIUM.** righttoknow and planningalerts, then metabase, proxy and openaustralia
once their questions are answered.

**Phase 3, the cloud backend.** Terraform module for the chosen provider, the expiry mechanism, and
`make dev-extend`. Needs the provider decision and spend sign-off first.

**Phase 4, retire Vagrant.** Only once a service is proven on the new path: delete `Vagrantfile`, the `vagrant`
and `clobber` Makefile plumbing, and the Vagrant sections of `README.md` and `INSTALL.md`, in one change together
with their references. Removing config while leaving references behind is a known failure mode.

Coexistence in the meantime is cheap: Vagrant generates its own inventory and passes it with `-i`, so it never
collides with `inventory/dev/`.

## Reference: checks that need an Apple Silicon Mac

Nobody has run any of this on arm64. In rough priority order:

1. Does a thin `openssh-server` layer on `geerlingguy/docker-ubuntu2404-ansible` work on arm64, and can Ansible
   SSH into it?
2. metabase: nested Docker *plus* systemd in one container. No authoritative guidance exists for the cgroup
   namespace setting, so this needs trying rather than assuming.
3. Does Capistrano reach a host through a published loopback port?
4. After `docker compose stop` then `start`, does systemd bring up everything Ansible enabled? The geerlingguy
   images strip some units, so confirm enablement really is honoured rather than assuming it from how systemd
   boots. Then note which boot behaviours the restart does *not* cover, so the cloud backend's remaining purpose
   is based on evidence.
5. Only if amd64 containers on the Mac are wanted rather than going to the cloud: does Rosetta binfmt
   registration reach nested container mount namespaces? The kernel's binfmt_misc `F` flag suggests it should,
   but the Lima docs do not say so and it is unconfirmed.

## Reference: verification, per service

1. `ansible -i inventory/dev/executable <host> -m ping` succeeds from `control`.
2. `make check-<service>` clean, then `make apply-<service>` with `failed=0`. Compare against issue #445, which
   records the current theyvoteforyou failure ("Apt add passenger to list - signatures couldn't be verified" and
   `external/rvm.ruby : Update rvm`), so new breakage is distinguishable from old.
3. A Capistrano deploy from the application repo reaches the host and the site responds over HTTPS with the dev
   certificate.
4. For morph and postal, `docker run` of the amd64 scraper image succeeds inside the host.
5. Fresh-contributor test, on a machine with no vault passphrases and no `terraform.pem`, following only the
   documented steps. This is the criterion most likely to fail and worth testing earliest.
6. Memory, with the largest realistic subset running. Document which subsets fit rather than implying
   all-at-once works.
7. Both platforms before a phase is called done.

## Reference: loose ends worth doing anyway

- `buildstep`'s `.github/workflows/build-and-push.yml` sets up QEMU and buildx but never passes a `platforms:`
  argument, so it only publishes the runner's architecture. Adding `platforms: linux/amd64,linux/arm64` would make
  the `heroku-24` stack multi-arch, since its `gliderlabs/herokuish:v0.10.3-24` base already is. `cedar-14` cannot
  follow, because `heroku/cedar:14` is amd64-only upstream. Nobody has yet read buildstep's Dockerfiles for
  amd64-specific assumptions. **Doing this would remove morph's amd64 constraint entirely.**
- morph's `platform: linux/amd64` cites sorbet/sorbet#4119, which is now closed. `sorbet-static` ships
  `aarch64-linux` today and morph's lock is simply old at `0.5.10262`. The first aarch64 release is unconfirmed.
- `roles/requirements.yml` should gain `community.docker` explicitly; it is available today only because
  `requirements.txt` pins the batteries-included `ansible~=2.10.7`, which bundles it.
- `CONTEXT.md`'s "Out of scope" section says development "is not part of this vocabulary" and points at the empty
  `[development]` group as a Vagrant artefact. `DEV_HOSTS`, `DEV_BACKEND` and `inventory/dev/` contradict that, so
  the glossary needs revising alongside the first implementation change. A development *backend* is not a
  development *stage*.

-------------------------------------

# Proposed update of docs/adr/0001-local-ansible-testing-moves-to-docker.md

Everything below the front matter is offered as the new body of that ADR. Nothing has been written to it yet, so
argue with this text rather than with the file.

Two things to settle while reviewing. The `status` reads `proposed`; change it to `accepted` when signed off. And
the title no longer quite matches the filename, because the decision has grown a second backend. ADR filenames
are conventionally frozen once numbered, so leaving the filename alone is the normal choice, but say if you would
rather retire 0001 and give this its own number instead.

```markdown
---
status: proposed
date: 2026-08-10
---

# Local Ansible testing will move from Vagrant to Docker/Compose, and to rented hosts where Compose cannot

Vagrant + VirtualBox is increasingly poorly supported outside Debian-based Linux (see README "Supported
Platforms"), and full VMs are heavier than needed just to exercise Ansible roles. Local Ansible testing moves to
Docker/Compose hosts that are close enough to a real host to be a useful provisioning target, in the vein of
geerlingguy's Ansible test containers. This keeps the role of testing the Ansible setup itself, not application
development, which happens in each application's own repository and devcontainer.

Expanded 2026-08-20, after investigating whether containers can serve every service. They cannot, so a second
backend is part of this decision. Implementation detail and the per-service work list live in
`docs/dev-hosts-implementation-plan.md`, which is expected to go stale and be deleted once the work is done.

A second reason Vagrant is a dead end, unrelated to Apple Silicon: Canonical stopped publishing Vagrant boxes from
Ubuntu 24.04 onward, citing Vagrant's move to the Business Source Licence. There will never be an official
`ubuntu/noble64`. Upstream Ubuntu cloud images and the geerlingguy base images are both unaffected, so moving off
Vagrant boxes improves the position rather than trading one dead end for another.

## Two backends, one abstraction

- **`compose`** runs development hosts as local containers. Fast, free, the default.
- **`binarylane`** rents real x86_64 hosts, assembled by Terraform and destroyed when finished.

The conceptual model is deliberately blunt: **AWS and Linode are OAF live infrastructure, and a separate provider
is development.** A separate provider means a separate bill, no chance of a development host being mistaken for a
live one, and the freedom to destroy everything in the development account without a second thought.

Both are hidden behind one interface, so `make check-<service>` does not care which is in use: `DEV_HOSTS` names
which hosts to bring up, `DEV_BACKEND` selects the backend, and a new dynamic inventory script reports whichever
hosts exist. "Hosts" because that is Ansible's word and `CONTEXT.md`'s. Selection happens through the environment
and the Makefile, never by editing a tracked file, and deliberately not through `devcontainer.json`, whose
`runServices` cannot expand one variable into several services.

Which provider is still open. BinaryLane is Australian, cheap, and fits the model cleanly, but its Terraform
provider is community tier where every alternative surveyed is partner tier, and whether it can issue scoped API
tokens is unconfirmed. DigitalOcean has a Sydney region, per-second billing better suited to
iterate-and-destroy loops, and the most granular token scopes of the five surveyed.

## Why a second backend is needed at all

Three independent reasons, any one of which would be sufficient:

**Some services have no arm64 path.** `ppa:xapian/backports` publishes no arm64 build of the `libxapian-dev
1.4.22` that openaustralia pins. `ghcr.io/postalserver/postal:3.3.7` is a single-platform amd64 image. Every
`openaustralia/buildstep` tag is amd64, and morph routes all scraper traffic through the amd64-only
`openaustralia/morph-mitmdump`.

**Docker-in-Docker cannot be combined with emulation.** morph and postal both need a working Docker daemon inside
the development host. The devcontainers docker-in-docker guidance states plainly that this will not work with an
emulated x86 image on Docker Desktop on an Apple Silicon Mac, because host and container must share a chip
architecture. On x86_64 Linux both work under Compose; it is only Apple Silicon that forces the cloud.

**Containers reboot only as far as userspace.** `docker compose stop` then `start` keeps the container and its
filesystem and restarts systemd, which boots into its default target and starts whatever is enabled in
`multi-user.target.wants/`, so "is this service enabled so it starts on boot?" is answerable on a container. What
is not is anything below systemd: kernel and initramfs, `/etc/fstab` and mount units against real block devices,
`sysctl` settings that are namespaced or read-only in a container, cloud-init, a role that triggers a reboot
handler, unattended-upgrades' automatic reboot, and whether the host actually comes back, which is the failure a
reboot test exists to catch. This is a partial gap, and so a weaker reason than the two above: it matters for the
roles that manage mounts, swap and kernel settings, and little for the rest.

The cloud backend is therefore not a macOS workaround. It is also the answer for a contributor on an 8GB machine,
who can run the whole fleet remotely rather than not at all.

## Where each service lands

| Tier | Services | What it needs |
|---|---|---|
| Easy | theyvoteforyou, righttoknow, planningalerts, and the database stand-ins | Compose as-is |
| Medium | metabase, proxy, openaustralia | Config and design work, still Compose |
| Hard | morph, postal | Cloud backend on Apple Silicon |

The tiers say where a service can be *provisioned*. Boot testing is orthogonal, and only partly a gap: unit
enablement is testable on a container by stopping and starting it, whereas kernel, mount and does-it-come-back
questions need a cloud host, for any service including the Easy ones.

Two of the Medium three are decisions rather than work. openaustralia needs `libxapian-dev 1.4.22`, so either the
library gets built from source alongside the bindings the role already compiles, or the pin is relaxed to
Ubuntu's arm64 1.4.18, which is an ABI decision; without one of those it drops to Hard. proxy is the only xenial
host, and xenial is now unsupportable on *both* backends, since the geerlingguy xenial image is amd64-only and
frozen since 2021 and BinaryLane's oldest Ubuntu is 20.04. Since 16.04 left standard support in 2021, moving
proxy to a supported release is the cheaper fix.

Swap is not a blocker. `geerlingguy.swap` only runs where `swap_file_size_mb` is defined, which is planningalerts
and openaustralia alone, so leaving it undefined for development hosts skips it. That role goes untested on the
Compose backend, which is an accepted gap.

## Expiry: hosts go away unless you ask for more

Cloud hosts are created with an expiry and the default is that they die. Extending is a deliberate act. This is
preferred over a central reaper because it **fails safe**: a sweeper that breaks leaves every host running and
billing, whereas an expiry that breaks still leaves the host expiring.

One detail decides how it is built. BinaryLane bills "from the moment your server is created ... until the server
is cancelled", and cancelling is a separate action from powering off, so **a host shutting itself down does not
stop the bill.** Expiry has to call the provider API to cancel the host, not merely halt it, or the host sits
there dead and still charging. That leaves a real trade-off: a self-cancelling host needs an API token on a
disposable box that anyone may hand-hack, and if the provider cannot issue a delete-only token that same token
can create hosts too; halting locally and cancelling from a scheduled job on OAF's own token avoids the
credential but makes the money depend on a central job, so it fails open.

**AWS was considered and rejected.** `InstanceInitiatedShutdownBehavior=terminate` would let a plain `shutdown`
inside a host terminate it with no credential and no sweeper, which is the fail-safe property wanted, for free.
But AWS documents the attribute as firing on "a command such as **shutdown** or **poweroff**" and does not
mention reboot at all, so there is no documented guarantee that rebooting is safe. Since a failed reboot is
precisely what reboot testing exists to catch, an arrangement where it destroys the host and its evidence is the
wrong way round. From the same page, `halt` "doesn't initiate a shutdown", it parks the CPU while the host keeps
running and billing, so it is useless for expiry as well.

Expiry should warn before it acts. Losing a development host should be cheap by design: anything worth keeping is
in Ansible, and a host that cannot be recreated from the playbooks is a bug in the playbooks.

## Cost, and the absence of a safety net

BinaryLane prices read 2026-08-20, inc GST: 2GB A$10.78/month, 4GB A$21.56, 8GB A$43.12. Hourly is prorated from
the monthly price, so a 2GB host is about 1.4c/hour. Three hosts for an afternoon is about A$0.16 and the whole
fleet for a working day about A$1.52. The fleet left running for a month is about A$150.

Ordinary use is therefore negligible and the entire risk is forgotten hosts: one month of forgetting costs about
ninety days of correct use. Two findings make that a human control rather than a technical one:

- **No provider surveyed offers a hard spending cap**, only alerts. DigitalOcean's documentation says outright
  that a billing threshold "is not a spending cap and does not limit how much you can use".
- **No provider offers instance TTL or auto-destroy**, which is why expiry is ours to build.

## Inventory layout

The existing sources move under a directory of their own so `dev` sits beside them as a peer:
`inventory/ec2-hosts` becomes `inventory/cloud/ec2-hosts`, `inventory/aws_ec2.yml` becomes
`inventory/cloud/aws_ec2.yml`, and `inventory/dev/executable` is added. `cloud` rather than `prod` because the
static file holds both stages and postal is a Linode host; `live` would also do and reads better against the
model above. The dynamic file keeps its name because the `amazon.aws.aws_ec2` plugin documents a requirement that
its config file end in `aws_ec2.yml`.

## Consequences

- Recurring third-party spend is a financial commitment and needs sign-off before the cloud backend is adopted,
  separately from the technical decision recorded here. OAF may qualify for provider nonprofit or open-source
  credits; the figures found came from secondary sources and need confirming.
- Each contributor using the cloud backend holds an API token that can create and destroy hosts. That is a new
  credential class for this repository, to be scoped as narrowly as the provider allows and never committed.
- Development hosts on the Compose backend need `privileged: true` and cgroup access for systemd, so they are
  more privileged than a Vagrant VM was.
- `Vagrantfile` and its Makefile plumbing, docs and `group_vars/development.yml` addresses stay until a service is
  proven on the new path, then go in one change. Vagrant still works on Linux x86_64 in the meantime, and does not
  collide with the new backends because it supplies its own inventory. Removing config while leaving references
  behind is a known failure mode.
- `CONTEXT.md`'s "Out of scope" section says development "is not part of this vocabulary" and points at the empty
  `[development]` group as a Vagrant artefact. `DEV_HOSTS`, `DEV_BACKEND` and `inventory/dev/` contradict that, so
  the glossary needs revising alongside the first implementation change. A development *backend* is not a
  development *stage*, and that distinction is worth stating there.
- A contributor without vault passphrases still cannot use any of this until the encrypted variables the
  development path touches have fixture values. Until then issue #96 stays open and issue #555's criterion about
  working "without private/internal context" is unmet.
```
