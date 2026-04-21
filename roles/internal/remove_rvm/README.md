# `remove_rvm`

Undoes a system-wide RVM installation as performed by `roles/external/rvm.ruby`

## What it removes

| Item | Path |
|------|------|
| RVM installation directory | `/usr/local/rvm` |
| Shell profile script | `/etc/profile.d/rvm.sh` |
| Ruby binary symlinks | `/usr/local/bin/{ruby,irb,gem,rake,erb,rdoc,ri,executable-hooks-uninstaller}` |
| Bundler binary symlinks | `/usr/local/bin/{bundle,bundler}` |

Symlinks are only removed if they exist, are actually symlinks, and point into `/usr/local/rvm` —
so it is safe to run even if another ruby installation owns those names.

## What it does NOT remove

- The RVM installer script downloaded to `/tmp/rvm-installer.sh` (ephemeral, already gone)
- GPG keys imported to the system keyring during install

## Usage

```yaml
- hosts: somehost
  roles:
    - remove_rvm
```

* No variables required.
* The role assumes `rvm.ruby` was run as root, ie a system install
