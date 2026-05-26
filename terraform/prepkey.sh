#!/bin/bash
# Used in deployer-key.tf to get local public key 
# which is used for creating / accessng AWS ec2 instances
#
# Usage:
#   ./prepkey.sh # trys to find open au / oaf keys, drops back to id_rsa
#   GITHUB_USER=user-name ./prepkey.sh # use your first id_rsa key from github
#   SSH_RSA_PUBLIC_KEY_FILE=~/.ssh/id_ed25519-CUSTOM-NAME ./prepkey.sh # specify the file directly

set -o pipefail

create_json() {
  grep '^ssh-' | head -1 | jq -R '{id_rsa: .}'
}

get_first_local_key() {
  local f
  for f in \
    "${SSH_PUBLIC_KEY_FILE:-}" \
    ~/.ssh/id_{ed25519,rsa}*oaf*.pub \
    ~/.ssh/id_{ed25519,rsa}*OAF*.pub \
    ~/.ssh/id_{ed25519,rsa}*open*au*.pub \
    ~/.ssh/id_{ed25519,rsa}*OPEN*AU*.pub \
    ~/.ssh/id_{ed25519,rsa}.pub; do
    # glob may not match, skip literal unmatched patterns
    [ -n "$f" ] && [ -s "$f" ] && create_json < "$f" && return 0
  done
  return 1
}

if [ -n "$GITHUB_USER" ]; then
  curl -sf "https://github.com/${GITHUB_USER}.keys" | \
    create_json
elif get_first_local_key; then
  : # handled inside the function
else
  echo "Error: Unable to find local id_rsa public key, set GITHUB_USER or SSH_RSA_PUBLIC_KEY_FILE" >&2
  exit 1
fi
