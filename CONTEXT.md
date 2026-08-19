# Infrastructure

The vocabulary this repository uses for OpenAustralia Foundation's servers and the two layers of configuration
that create and configure them. This is a glossary only. Setup, commands and per-service detail live in
`README.md`, `AGENTS.md` and `docs/`.

## Language

### The three layers

**Assembling**:
Creating or updating the infrastructure a host needs, with Terraform, before Ansible touches it.
_Avoid_: provisioning, building, standing up

**Provisioning**:
Configuring a host with Ansible, once it exists.
_Avoid_: deploying, setting up, configuring (when the layer matters)

**Deployment**:
Installing or updating an application's own code with Capistrano, run from that application's repository and never
from here.
_Avoid_: provisioning, release, push

### What we manage

**Service**:
A unit this repository assembles, provisions, or both, and the thing `make check-<service>` and
`make apply-<service>` name.
_Avoid_: module, role (each means one layer's artefact for a service, not the service itself), component,
collection

**Building block**:
An Ansible role shared by several services rather than belonging to one.
_Avoid_: common role, base role, shared role

**Cleanup role**:
An Ansible role whose only job is to remove a retired tool from a host, and which should never be needed twice.
_Avoid_: uninstall role, teardown role

**Host**:
One machine, whether EC2 or Linode.
_Avoid_: server, box, instance, node

### Stages and environments

**Stage**:
A deployment target of one service, either production or staging. It says nothing about whether the two share a
host, because for some services they do.
_Avoid_: environment (it means something else here), tier, deploy target

**Environment**:
One of the two interchangeable sets of hosts, blue or green, that a service can run on, only one of which takes
traffic at a time.
_Avoid_: fleet, colour, live/new, new/old

**Cutover**:
Shifting traffic from one environment to the other, or from a retired service to its replacement. No application
code is installed by a cutover.
_Avoid_: blue/green deployment, release, switch

### OAF's own words

**OAF collection**:
One of OAF's five public-facing offerings: Planning Alerts, Right to Know, They Vote for You, OpenAustralia.org.au
and morph.io.
_Avoid_: service, product, site

**Ansible collection**:
A Galaxy collection installed into `collections/` by `make requirements`.
_Avoid_: dependency, package

Bare "collection" is never used in this repository, because both senses above are load-bearing: one is org-wide
naming, the other is an Ansible config path and a gitignored directory. Always qualify it.

## Out of scope

**development** is not part of this vocabulary. Capistrano uses it as a stage name and `inventory/ec2-hosts` has an
empty `[development]` group for `Vagrantfile`, but this repository assembles and provisions production
infrastructure, so there is no development stage to provision here.
