#!/bin/bash

#
# Go to the same path of the forked repository
# 
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
PATH=$(extract_path "$URL")

# substitute organization with 'iocanel'
FORK_URL="https://$HOST/iocanel/$REPOSITORY_NAME$PATH"
echo "open -t $FORK_URL" >> $QUTE_FIFO