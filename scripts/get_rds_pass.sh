#!/bin/bash


ansible-playbook ./scripts/show_secrets.yml | \
    sed -n 's/.*Password: \(.*\)/\1/p' | \
    # trim the " at the end if present
    sed 's/"$//'
