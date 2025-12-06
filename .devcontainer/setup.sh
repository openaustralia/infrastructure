#!/bin/bash
set -e

echo "Setting up OpenAustralia Infrastructure development environment..."

# Install jq and other dependencies
echo "Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y jq apt-transport-https ca-certificates gnupg curl

# Install Google Cloud CLI
echo "Installing Google Cloud CLI..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# Install Keybase
echo "Installing Keybase..."
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
# Note: Using prerelease to ensure latest compatible version for headless systems
sudo apt install -y ./keybase_amd64.deb
rm keybase_amd64.deb

# Install Ruby gems
echo "Installing Ruby gems..."
gem install bundler
bundle install

# Use Makefile to set up venv and install Ansible roles
echo "Setting up Python venv and Ansible roles using Makefile..."
make roles

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "IMPORTANT: Keybase is installed but not configured."
echo "Please run the following to set up Keybase:"
echo ""
echo "  1. Run 'keybase login' to authenticate"
echo "  2. Run 'run_keybase' to start Keybase services"
echo "  3. Run 'keybase id' to verify your identity"
echo ""
echo "For headless setup, you can use:"
echo "  bash bin/headless-keybase.sh"
echo ""
echo "After Keybase is running, vault passwords will be"
echo "available via the .keybase symlink and vault password files."
echo ""
echo "See .devcontainer/SECRETS.md for more information on"
echo "managing secrets in Codespaces."
echo "=========================================="
