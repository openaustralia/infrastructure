#!/bin/bash
# {{ ansible_managed }}
#
# Copy the Let's Encrypt certificate that Caddy manages for the web
# interface to the Postal SMTP listener, replacing the self-signed
# placeholder created at provision time. Restarts the SMTP container only
# when the certificate has actually changed.

set -e

CADDY_CERT_DIR="/opt/postal/caddy-data/caddy/certificates/acme-v02.api.letsencrypt.org-directory/{{ postal_web_hostname }}"
CONFIG_DIR="/opt/postal/config"

# Caddy may not have obtained a certificate yet (e.g. on first provision
# before DNS has propagated). That's fine; try again on the next run.
if [ ! -f "$CADDY_CERT_DIR/{{ postal_web_hostname }}.crt" ]; then
  exit 0
fi

if cmp -s "$CADDY_CERT_DIR/{{ postal_web_hostname }}.crt" "$CONFIG_DIR/smtp.cert"; then
  exit 0
fi

cp "$CADDY_CERT_DIR/{{ postal_web_hostname }}.crt" "$CONFIG_DIR/smtp.cert"
cp "$CADDY_CERT_DIR/{{ postal_web_hostname }}.key" "$CONFIG_DIR/smtp.key"
chmod 600 "$CONFIG_DIR/smtp.cert" "$CONFIG_DIR/smtp.key"

/usr/bin/postal dc "restart smtp"
