#!/bin/bash
set -e

echo "Setting up OpenAustralia Infrastructure development environment..."

# Install jq (required by prepkey.sh) and other dependencies
echo "Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y jq apt-transport-https ca-certificates gnupg curl

# Install Google Cloud CLI
echo "Installing Google Cloud CLI..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# Install Python dependencies (Ansible and related tools)
echo "Installing Python dependencies..."
python3 -m pip install -r requirements.txt

# Install Ruby gems
echo "Installing Ruby gems..."
gem install bundler
bundle install

# Install Ansible Galaxy collections and roles
echo "Installing Ansible Galaxy collections..."
ansible-galaxy collection install -r roles/requirements.yml
echo "Installing Ansible Galaxy roles..."
ansible-galaxy install -r roles/requirements.yml -p roles/external

echo "Setup complete!"
