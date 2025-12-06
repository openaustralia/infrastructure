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

# Install Ruby gems
echo "Installing Ruby gems..."
gem install bundler
bundle install

# Use Makefile to set up venv and install Ansible roles
echo "Setting up Python venv and Ansible roles using Makefile..."
make roles

echo "Setup complete!"
