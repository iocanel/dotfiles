#!/bin/bash

# Open terminal in GitLab repository
# Determine the ssh URL of the repository the specified URL (first argument) belongs to.
# Clone the repository under ~/workspace/src/GITLAB_HOST/ORGANIZATION/REPOSITORY_NAME

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
WORKSPACE=$(build_workspace_path "$HOST" "$ORGANIZATION")

# Clone repo in kitty and keep terminal open afterwards
kitty --class EditorTerm -e bash -c "mkdir -p $WORKSPACE; cd $WORKSPACE; if [ ! -d ${REPOSITORY_NAME} ]; then $(declare -f smart_clone); $(declare -f get_clone_method); $(declare -f build_ssh_url); $(declare -f build_https_url); $(declare -f clone_with_fallback); smart_clone '$HOST' '$ORGANIZATION' '$REPOSITORY_NAME' '$REPOSITORY_NAME'; fi; cd $REPOSITORY_NAME; exec fish"
popd