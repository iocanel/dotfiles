#!/bin/bash

# Clone a GitHub repository
# Determine the ssh URL of the repository the specified URL (first argument) belongs to.
# Clone the repository under ~/workspace/src/github.com/ORGANIZATION/REPOSITORY_NAME

URL=$1
ORGANIZATION=$(echo $URL | sed -n 's/.*github.com\/\([^\/]*\)\/.*/\1/p')
REPOSITORY_NAME=$(echo $URL | sed -n 's/.*github.com\/[^\/]*\/\([^\/]*\).*/\1/p')
CLONE_URL_SSH="git@github.com:$ORGANIZATION/$REPOSITORY_NAME.git"

# Clone repo in kitty and keep terminal open afterwards
kitty --class EditorTerm -e bash -c "mkdir -p ~/workspace/src/github.com/$ORGANIZATION; cd ~/workspace/src/github.com/$ORGANIZATION; git clone $CLONE_SSH_URL; exec fish"
popd
