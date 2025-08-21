#!/bin/bash
echo "Enter vault password for EC2 vault (from /keybase/team/oaforgau.sysadmin/.ec2-vault-pass):" >&2
read -s -r password
echo "$password"