#!/bin/bash

# A little wrapper script used to set the correct version of ruby
# when it's run from the postfix pipe for incoming email handling
# This is the only way I managed to figure out to get things working
# but it doesn't feel like it's the most concise approach.
# TODO: Figure out if there's a better way

PATH=/home/deploy/.rbenv/bin:/home/deploy/.rbenv/shims:$PATH
source "$1"
exit $?
