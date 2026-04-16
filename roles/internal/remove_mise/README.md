# `remove_mise`

Removes a mise installation (as found on staging server)

## What it removes

| Item | Path |
|------|------|
| mise binary | `~/.local/bin/mise` |
| Tools, plugins, shims | `~/.local/share/mise` |
| Config files | `~/.config/mise` |

## What it does NOT remove

- Shell integration lines in `.bashrc` / `.bash_profile` / `.zshrc` — none were added
  in staging
- `/etc/profile.d` entries — none present

If shell integration was added on other hosts, check for and remove the following lines manually:
```bash
eval "$(~/.local/bin/mise activate bash)"   # or zsh/fish variant
export PATH="$HOME/.local/bin:$PATH"
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `mise_user_homes` | `/root` and `/home/deploy` | Home directories |

## Usage

```yaml
- hosts: somehost
  roles:
    - role: remove_mise
```
