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

# The check above compares only the certificate, so the certificate is written
# last and acts as the commit point: if the key fails to land, the old
# certificate stays put and the next run tries again. Writing the certificate
# first would leave a new certificate paired with a stale key, and every later
# run would match on the certificate and skip over the mismatch.
#
# install sets the ownership and mode in one step, because the smtp container
# reads these as uid 999 rather than root. Writing to a temporary name and
# renaming means the SMTP listener never sees a half-written file.
install -o {{ postal_container_uid }} -g {{ postal_container_gid }} -m 640 "$KEY_FILE" "$CONFIG_DIR/smtp.key.tmp"
mv "$CONFIG_DIR/smtp.key.tmp" "$CONFIG_DIR/smtp.key"

install -o {{ postal_container_uid }} -g {{ postal_container_gid }} -m 640 "$CERT_FILE" "$CONFIG_DIR/smtp.cert.tmp"
mv "$CONFIG_DIR/smtp.cert.tmp" "$CONFIG_DIR/smtp.cert"

/usr/bin/postal dc "restart smtp"
