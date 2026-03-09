#!/bin/bash

#
# Unified PR/MR review script - detects GitHub vs GitLab and calls appropriate script
#

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1

if is_github "$URL"; then
    exec "$SCRIPT_DIR/github-pr-review.sh" "$URL"
else
    exec "$SCRIPT_DIR/gitlab-mr-review.sh" "$URL"
fi
