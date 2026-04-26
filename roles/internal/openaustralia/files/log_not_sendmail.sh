#!/bin/bash

# Log emails that would have been sent

LOGDIR=~/log/mail/
KEEP=500

mkdir -p "$LOGDIR"

FILENAME=$(date +%Y%m%dT%H%M%S)_$$.log
echo "Logging email on stdin to $LOGDIR/$FILENAME ..."
cat >> "$LOGDIR/$FILENAME"

# Only keep latest KEEP emails
ls -t "$LOGDIR" | egrep "^[0-9]*T[0-9]*_[0-9]*\.log$" | tail -n +$((KEEP + 1)) | xargs -r "-I{}" rm "$LOGDIR/{}"
exit 0
