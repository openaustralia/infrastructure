# Local development with Lima (Apple Silicon / amd64 via Rosetta)

Lima is an alternative to Vagrant for spinning up the local Ansible
development fleet. Unlike Vagrant + VirtualBox, it runs on Apple Silicon
(M1+) using Apple's Virtualization.framework with Rosetta to translate
amd64 instructions at near-native speed. Every guest is `linux/amd64`,
matching production exactly.

The Vagrant flow remains supported for contributors who prefer it; both
paths use the same Ansible playbook against the same `development` host
group.

## Requirements

| Host                           | Hypervisor (auto-picked) | Performance                |
| ------------------------------ | ------------------------ | -------------------------- |
| macOS 13+ on Apple Silicon     | `vz` + Rosetta           | Fast — Rosetta translation |
| macOS on Intel                 | `vz` (or `qemu`)         | Native                     |
| Linux on amd64                 | `qemu` + KVM             | Native                     |

Lima ≥ **0.20** is required for the Rosetta-on-vz support that this
setup depends on.

### macOS one-time setup

```bash
brew install lima socket_vmnet

# Allow Lima to manage the shared L2 network without prompting per command.
# `socket_vmnet` is the macOS bridge that gives both host↔VM and VM↔VM
# connectivity — the closest equivalent to Vagrant's private host-only
# network.
limactl sudoers | sudo tee /etc/sudoers.d/lima

# (Optional) Verify Rosetta and macOS version.
sw_vers -productVersion        # must be ≥ 13.0
limactl --version              # must be ≥ 0.20
```

### Linux one-time setup

```bash
# Debian/Ubuntu:
sudo apt install lima qemu-system-x86 qemu-utils
```

`socket_vmnet` is macOS-only. On Linux, `lima/bin/lima-up` falls back to
the `user-v2` network, which gives VM↔VM connectivity but reaches VMs
from the host via port forwards rather than direct IP. Most Linux
contributors will still find Vagrant + VirtualBox more convenient there;
Lima on Linux is provided primarily for amd64-Linux contributors who
also want to test changes on Apple Silicon machines.

## Day-to-day workflow

```bash
make lima-requirements                              # one-time per checkout
HOSTS=mysql.test,web.planningalerts.test \
  make lima-up                                      # subset of fleet
sudo make lima-hosts-sync                           # add VM names to /etc/hosts
HOSTS=mysql.test,web.planningalerts.test \
  make lima-provision                               # run site.yml

# To re-run only a tagged subset (same env vars as `make apply-*`):
TAGS=apache HOSTS=web.planningalerts.test make lima-provision

# Status / teardown:
make lima-status
HOSTS=mysql.test make lima-destroy                  # one VM
make lima-clean                                     # all VMs + /etc/hosts block
```

## Memory and CPU

Defaults: 2 GB RAM, 2 vCPU per VM (matching the Vagrant defaults
described at [README.md](../README.md)). The full fleet is 14 VMs and
will not fit in a typical laptop. Boot only what you need — usually
mysql or postgresql plus the one app server you're working on.

Override per `make lima-up` invocation:

```bash
LIMA_MEMORY=4GiB LIMA_CPUS=4 make lima-up HOSTS=web.planningalerts.test
```

## How it works

1. [lima/hosts.yml](../lima/hosts.yml) declares the fleet (one entry per
   inventory hostname, with Ubuntu release, groups, and aliases).
2. `lima/bin/lima-up` reads it, picks the matching template from
   [lima/templates/](../lima/templates/), substitutes the hostname / CPU /
   memory / network block, and calls `limactl create` + `limactl start`.
3. Each VM's `provision:` block (in the template) sets the hostname,
   grants the Lima user's SSH key to `root`, and ensures `python3` is
   present — so Ansible's existing `remote_user = root` and `gather_facts`
   work without changes.
4. After all VMs are up, `lima-up` writes
   [lima/inventory/lima-hosts](../lima/inventory/) — an Ansible inventory
   with the same group shape as the `Vagrantfile`.
5. `make lima-provision` invokes `.venv/bin/ansible-playbook -i
   lima/inventory/lima-hosts site.yml` with the same tag/skip/verbose
   plumbing the rest of the Makefile uses.

## Capistrano deploys to Lima VMs

The `lima:shared` network gives the macOS host direct L3 access to VM
IPs, so once `lima-hosts-sync` has updated `/etc/hosts`, Capistrano
flows from app repositories (Alaveteli, planningalerts-app, etc.) work
exactly as they do with Vagrant. For example, with `server:
righttoknow.test` in `config/deploy.yml`:

```bash
cd ../alaveteli
bundle exec cap -S stage=development deploy:cold
```

## Troubleshooting

### `limactl start` hangs on first boot

First-boot downloads the Ubuntu cloud image (~500 MB per release). Watch
progress with `limactl shell <instance> -- journalctl -u cloud-final -f`
once SSH is reachable, or `tail -F ~/.lima/<instance>/serial.log`.

### Provision probe fails: "root SSH and python3 ready"

Inspect the per-VM serial log:

```bash
tail -200 ~/.lima/<instance>/serial.log
```

Common causes: cloud-init didn't finish (bad Ubuntu image URL), Lima
default user differs from `$USER` (set `LIMA_USER=<user>` in the
environment before `make lima-up`), or the template's
`PermitRootLogin` edit failed.

### `vagrant up` and `make lima-up` together

Both can coexist on the same checkout. They use different VM tools and
different inventories. The Ansible-side change (`group_vars/development.yml`
referring to `mysql.test` rather than `192.168.56.10`) is satisfied by:

- **Vagrant:** `vagrant-hostsupdater` writes the macOS host /etc/hosts,
  and the new `internal/dev-hosts` role writes the guest /etc/hosts.
- **Lima:** `lima-hosts-sync` writes the macOS host /etc/hosts, and the
  same `internal/dev-hosts` role writes the guest /etc/hosts.

### "address already in use" port clashes

Lima auto-assigns SSH ports starting at 60022 — usually no conflict.
For port forwards to host (e.g. Capistrano needs port 22 on the VM
IP), `lima:shared` uses the assigned VM IP so the host port 22 is not
touched.

## Removing the Lima setup

```bash
make lima-clean             # destroy all VMs, remove /etc/hosts block
brew uninstall lima socket_vmnet
sudo rm /etc/sudoers.d/lima
```
