# `remove_rbenv`

Undoes a rbenv installation as performed by `roles/external/zzet.rbenv`

## What it removes

| Item | Path |
|------|------|
| rbenv system installation | `{{ rbenv_root }}` (default `/usr/local/rbenv`) |
| Shell profile script | `/etc/profile.d/rbenv.sh` |
| rbenv user installations | `~<user>/.rbenv` for each user in `rbenv_users` |

## What it does NOT remove

- Build dependencies installed via apt/yum/dnf
- GPG keys or other system-level changes

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `rbenv_root` | `/usr/local/rbenv` | System rbenv installation path |
| `rbenv_users` | `[]` | Users with per-user rbenv installations to remove |

## Usage

```yaml
- hosts: somehost
  roles:
    - role: remove_rbenv
```

For user installs:
```yaml
- hosts: somehost
  roles:
    - role: remove_rbenv
      rbenv_users:
        - deploy
```
