#!/bin/bash

# Create new GitLab issue
# Determine the URL to create a new issue for the repository

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
NEW_ISSUE_URL="https://$HOST/$ORGANIZATION/$REPOSITORY_NAME/-/issues/new"

echo "open -t $NEW_ISSUE_URL" >> $QUTE_FIFO