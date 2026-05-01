#!/bin/bash

LOGDIR=~/log/mail/
mkdir -p "$LOGDIR"

FILENAME=$(date +%Y%m%dT%H%M%S)_$$.log
cat >> "$LOGDIR/$FILENAME"
exit 0
