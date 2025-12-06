# Managing Secrets in GitHub Codespaces

This document explains how to securely manage Terraform, Ansible, and Keybase credentials in GitHub Codespaces.

## Overview

This repository uses several types of secrets:

1. **Ansible Vault passwords** - Stored in Keybase teams, accessed via `.keybase` symlink
2. **AWS credentials** - For Terraform state and AWS operations (`~/.aws/credentials`)
3. **Terraform secrets** - Additional secrets in `secrets.auto.tfvars`
4. **Cloudflare API tokens** - For DNS management

## Setting Up Keybase

Keybase is pre-installed in the Codespace. To configure it:

### 1. Login to Keybase

```bash
keybase login
```

Enter your Keybase credentials when prompted.

### 2. Start Keybase Services

For headless environments like Codespaces, use the provided helper script:

```bash
bash bin/headless-keybase.sh
```

This will:
- Start Keybase, KBFS, and redirector services
- Configure them as systemd user services
- Verify your Keybase identity

### 3. Verify Setup

Check that Keybase is running:

```bash
keybase id
```

You should see your Keybase identity displayed.

### 4. Create .keybase Symlink

The Makefile will attempt to create this automatically, but if needed:

```bash
# Find where Keybase mounted the filesystem
keybase config get -d -b mountdir

# Create symlink (usually to /run/user/$(id -u)/keybase/kbfs)
ln -sf $(keybase config get -d -b mountdir) .keybase
```

### 5. Verify Vault Passwords

Check that the vault password files are accessible:

```bash
ls -la .all-vault-pass .ec2-vault-pass .rtk-vault-pass .vault_pass.txt terraform.pem
```

These should be symlinks pointing to files in `.keybase/team/oaforgau.*`.

## Alternative: Using GitHub Codespaces Secrets

If you don't want to use Keybase, you can store secrets as GitHub Codespaces secrets and create the vault password files manually.

### Setting Codespaces Secrets

1. Go to your GitHub account settings
2. Navigate to **Codespaces** → **Secrets**
3. Add secrets for each vault password:
   - `ANSIBLE_VAULT_PASS`
   - `ANSIBLE_EC2_VAULT_PASS`
   - `ANSIBLE_RTK_VAULT_PASS`
   - `ANSIBLE_ALL_VAULT_PASS`

### Creating Vault Files from Secrets

Add this to your shell initialization or run manually:

```bash
# Create vault password files from Codespaces secrets
echo "$ANSIBLE_VAULT_PASS" > .vault_pass.txt
echo "$ANSIBLE_EC2_VAULT_PASS" > .ec2-vault-pass
echo "$ANSIBLE_RTK_VAULT_PASS" > .rtk-vault-pass
echo "$ANSIBLE_ALL_VAULT_PASS" > .all-vault-pass
chmod 600 .vault_pass.txt .ec2-vault-pass .rtk-vault-pass .all-vault-pass
```

**Note:** These files are in `.gitignore` and won't be committed.

## AWS Credentials

For Terraform and AWS operations:

### Option 1: AWS CLI Configuration

```bash
aws configure
```

This creates `~/.aws/credentials` with your access keys.

### Option 2: Codespaces Secrets

Set these as Codespaces secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

They'll be automatically available as environment variables.

### Option 3: Manual Creation

```bash
mkdir -p ~/.aws
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
EOF
chmod 600 ~/.aws/credentials
```

## Terraform Secrets

Create `terraform/secrets.auto.tfvars` with required secrets. Ask the team for the current contents.

```bash
# Example structure (values need to be provided by team)
cat > terraform/secrets.auto.tfvars << EOF
cloudflare_api_token = "your_token_here"
aws_access_key = "your_key_here"
aws_secret_key = "your_secret_here"
# ... other secrets
EOF
chmod 600 terraform/secrets.auto.tfvars
```

## Google Cloud Authentication

For Terraform's Google Cloud operations:

```bash
gcloud auth application-default login
```

Follow the prompts to authenticate.

## Security Best Practices

1. **Never commit secrets** - All secret files are in `.gitignore`
2. **Use restrictive permissions** - Set `chmod 600` on all credential files
3. **Rotate credentials** - Regularly update secrets, especially after leaving a project
4. **Use Keybase teams** - Preferred method for team secret sharing
5. **Delete secrets on exit** - Clean up when closing a Codespace (they're ephemeral anyway)

## Troubleshooting

### Keybase not starting

```bash
# Check service status
systemctl --user status keybase kbfs keybase-redirector

# Restart services
systemctl --user restart keybase kbfs keybase-redirector

# Check logs
journalctl --user -u keybase -f
```

### Vault password files not found

```bash
# Check if .keybase symlink exists and points to the right place
ls -la .keybase

# Verify Keybase teams
keybase team list-memberships

# Check if files exist in Keybase
ls -la .keybase/team/oaforgau.sysadmin/
```

### Permission denied errors

```bash
# Fix file permissions
chmod 600 .vault_pass.txt .ec2-vault-pass .rtk-vault-pass .all-vault-pass terraform.pem
```

## Getting Access

To access the Keybase teams and AWS accounts, contact the team administrators:
- Matthew Landauer (@mlandauer)
- James Polley (@jamezpolley)
