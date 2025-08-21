#!/bin/bash
echo "Enter vault password for DEFAULT vault (from /keybase/team/oaforgau.sysadmin/.vault_pass.txt):" >&2
read -s -r password
echo "$password"