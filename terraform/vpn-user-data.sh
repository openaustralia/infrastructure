#!/bin/bash
set -e

# OpenVPN Server Installation and Configuration with IAM Authentication
# This script installs OpenVPN and configures it to authenticate users via IAM
# Users must be in the '${vpn_iam_group}' IAM group to connect

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y openvpn easy-rsa python3-pip jq awscli

# Install boto3 for IAM authentication
pip3 install boto3

# Set up Easy-RSA for certificate generation
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

# Configure Easy-RSA
cat > vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "AU"
set_var EASYRSA_REQ_PROVINCE   "NSW"
set_var EASYRSA_REQ_CITY       "Sydney"
set_var EASYRSA_REQ_ORG        "OAF"
set_var EASYRSA_REQ_EMAIL      "admin@openaustraliafoundation.org.au"
set_var EASYRSA_REQ_OU         "IT"
set_var EASYRSA_KEY_SIZE       2048
set_var EASYRSA_CA_EXPIRE      3650
set_var EASYRSA_CERT_EXPIRE    3650
EOF

# Initialize PKI
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full server nopass

# Generate TLS auth key
openvpn --genkey secret /etc/openvpn/ta.key

# Copy certificates to OpenVPN directory
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

# Get server's private IP for routing
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create OpenVPN server configuration
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun

ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0

server 10.8.0.0 255.255.255.0

# Push routes to clients for VPC access
push "route 172.31.0.0 255.255.0.0"

# DNS - use VPC DNS
push "dhcp-option DNS 172.31.0.2"

# Client networking
client-to-client
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun

status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3

# IAM Authentication
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so openvpn
username-as-common-name
EOF

# Create PAM configuration for OpenVPN
cat > /etc/pam.d/openvpn <<EOF
auth required pam_exec.so /usr/local/bin/openvpn-iam-auth.sh
account required pam_permit.so
EOF

# Create IAM authentication script
cat > /usr/local/bin/openvpn-iam-auth.sh <<'AUTHSCRIPT'
#!/bin/bash

# OpenVPN IAM Authentication Script
# Validates IAM credentials and checks vpn-users group membership

# Read username (IAM Access Key ID) and password (IAM Secret Access Key)
read -r ACCESS_KEY_ID
read -r SECRET_ACCESS_KEY

# Log authentication attempt (without credentials)
logger -t openvpn-iam "Authentication attempt from user: $PAM_USER"

# Validate credentials using STS GetCallerIdentity
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"

# Try to get caller identity
if ! IDENTITY=$(aws sts get-caller-identity 2>/dev/null); then
    logger -t openvpn-iam "Authentication failed: Invalid credentials"
    exit 1
fi

# Extract username from ARN
IAM_USERNAME=$(echo "$IDENTITY" | jq -r '.Arn' | sed 's/.*:user\///')

if [ -z "$IAM_USERNAME" ]; then
    logger -t openvpn-iam "Authentication failed: Could not extract username"
    exit 1
fi

# Check if user is in vpn-users group
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

GROUPS=$(aws iam list-groups-for-user --user-name "$IAM_USERNAME" 2>/dev/null | jq -r '.Groups[].GroupName')

if ! echo "$GROUPS" | grep -q "^${vpn_iam_group}$"; then
    logger -t openvpn-iam "Authentication failed: User $IAM_USERNAME not in ${vpn_iam_group} group"
    exit 1
fi

logger -t openvpn-iam "Authentication successful: User $IAM_USERNAME"
exit 0
AUTHSCRIPT

chmod +x /usr/local/bin/openvpn-iam-auth.sh

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure NAT for VPN clients to access VPC
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE
iptables-save > /etc/iptables.rules

# Restore iptables on boot
cat > /etc/rc.local <<EOF
#!/bin/bash
iptables-restore < /etc/iptables.rules
exit 0
EOF
chmod +x /etc/rc.local

# Enable and start OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server

# Create client configuration template
cat > /root/client-template.ovpn <<EOF
client
dev tun
proto udp
remote REPLACE_WITH_SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
verb 3
auth-user-pass
EOF

logger -t openvpn-iam "OpenVPN server installation complete"
