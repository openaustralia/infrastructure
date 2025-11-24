#!/bin/bash
set -e

# Minimal bootstrap script for OpenVPN server
# Actual configuration is handled by Ansible

# Update system packages
apt-get update
apt-get upgrade -y

# Install Python for Ansible (if not present)
apt-get install -y python3 python3-pip

# Log instance initialization
logger -t user-data "OpenVPN server instance initialized - ready for Ansible configuration"
