# Lima per-release templates

Each `<release>.yaml` is a Lima instance config with placeholders that
[lima/bin/lima-up](../bin/lima-up) substitutes at render time.

Placeholders (only ever appear at substitution sites, never in comments):

| Placeholder         | Substituted with                              |
| ------------------- | --------------------------------------------- |
| `{{HOSTNAME}}`      | Full FQDN, e.g. `mysql.test`                  |
| `{{LIMA_INSTANCE}}` | Lima instance name, e.g. `mysql-test`         |
| `{{LIMA_USER}}`     | Default user inside the Lima VM (usually `$USER`) |
| `{{CPUS}}`          | CPU count (default 2; override via `LIMA_CPUS=`) |
| `{{MEMORY}}`        | Memory string, e.g. `2GiB` (override via `LIMA_MEMORY=`) |
| `{{NETWORK_BLOCK}}` | YAML block for `networks:` — `lima: shared` on macOS, `lima: user-v2` on Linux |

Every guest is pinned to `linux/amd64` regardless of host architecture.
On macOS 13+ Apple Silicon this runs via Rosetta translation through
Virtualization.framework.

Adding a new Ubuntu release: copy one of the existing templates and
update the cloud-image URL plus any release-specific package quirks
(e.g. xenial lacks `python-is-python3` and `sshd_config.d`).
