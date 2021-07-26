#!/bin/bash
# Used in deployer-key.tf to get local public key and use that on AWS

cat ~/.ssh/id_rsa.pub | head -1 | jq -R '{id_rsa: .}'
