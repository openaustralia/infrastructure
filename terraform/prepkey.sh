#!/bin/bash

cat ~/.ssh/id_rsa.pub | head -1 | jq -R '{id_rsa: .}'
