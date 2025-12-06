#!/bin/bash
set -e

echo "Setting up OpenAustralia Infrastructure development environment..."

# Install jq (required by prepkey.sh)
echo "Installing jq..."
sudo apt-get update && sudo apt-get install -y jq

# Install Python dependencies (Ansible and related tools)
echo "Installing Python dependencies..."
python3 -m pip install --user -r requirements.txt

# Install Ruby gems
echo "Installing Ruby gems..."
gem install bundler
bundle install

# Install Ansible Galaxy roles and collections
echo "Installing Ansible Galaxy roles and collections..."
ansible-galaxy collection install -r roles/requirements.yml
ansible-galaxy install -r roles/requirements.yml -p roles/external

echo "Setup complete!"
