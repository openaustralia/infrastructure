#!/bin/bash


p=$(ansible-playbook ./scripts/show_secrets.yml | \
    grep "RDS Admin Password:" | \
    sed 's/.*RDS Admin Password://' |\
    sed 's/\\nBackup Target Pass: .*$//' )


echo ${p}

