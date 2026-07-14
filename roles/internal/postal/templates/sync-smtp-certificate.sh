#!/bin/bash
# {{ ansible_managed }}
#
# Copy the Let's Encrypt certificate that Caddy manages for the web
# interface to the Postal SMTP listener, replacing the self-signed
# placeholder created at provision time. Restarts the SMTP container only
# when the certificate has actually changed.

set -e

CADDY_CERT_BASE="/opt/postal/caddy-data/caddy/certificates"
CONFIG_DIR="/opt/postal/config"

# Caddy files certificates under a per-issuer directory (Let's Encrypt normally,
# ZeroSSL as a fallback), so match whichever issuer actually holds our cert
# rather than hardcoding the issuer. Caddy may also not have obtained a
# certificate yet (e.g. on first provision before DNS has propagated); that's
# fine, try again on the next run.
shopt -s nullglob
certs=("$CADDY_CERT_BASE"/*/"{{ postal_web_hostname }}"/"{{ postal_web_hostname }}".crt)
CERT_FILE="${certs[0]-}"
if [ -z "$CERT_FILE" ]; then
  exit 0
fi
KEY_FILE="${CERT_FILE%.crt}.key"

if cmp -s "$CERT_FILE" "$CONFIG_DIR/smtp.cert"; then
  exit 0
fi

cp "$CERT_FILE" "$CONFIG_DIR/smtp.cert"
cp "$KEY_FILE" "$CONFIG_DIR/smtp.key"
chmod 600 "$CONFIG_DIR/smtp.cert" "$CONFIG_DIR/smtp.key"

/usr/bin/postal dc "restart smtp"
