#!/bin/bash

# Clone a GitHub repository
# Determine the ssh URL of the repository the specified URL (first argument) belongs to.
# Clone the repository under ~/workspace/src/github.com/ORGANIZATION/REPOSITORY_NAME

URL=$1
ORGANIZATION=$(echo $URL | sed -n 's/.*github.com\/\([^\/]*\)\/.*/\1/p')
REPOSITORY_NAME=$(echo $URL | sed -n 's/.*github.com\/[^\/]*\/\([^\/]*\).*/\1/p')
NEW_ISSUE_URL="https://github.com/$ORGANIZATION/$REPOSITORY_NAME/issues/new"

echo "open -t $NEW_ISSUE_URL" >> $QUTE_FIFO
