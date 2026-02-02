#!/bin/bash

# 
# Checkout a Github pull request for review
# Use smart cloning with SSH/HTTPS fallback
# 

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
PULL_REQUEST_NUMBER=$(extract_github_pr_number "$URL")

## Create a script to run in kitty
TEMP_SCRIPT=~/clone_pr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

TEMP_DIR=\$(mktemp -d)
cd \$TEMP_DIR
echo "Checking out pull request: $PULL_REQUEST_NUMBER into \$TEMP_DIR/$REPOSITORY_NAME..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$REPOSITORY_NAME"

# Check if clone was successful
if [ ! -d "$REPOSITORY_NAME" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $REPOSITORY_NAME
OWNER=\$(gh pr view --json headRepositoryOwner -q .headRepositoryOwner.login $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_NAME=\$(gh pr view --json headRepository -q .headRepository.name $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_URL="git@github.com:\$OWNER/\$OWNER_REPOSITORY_NAME.git"
git remote add \$OWNER \$OWNER_REPOSITORY_URL
git fetch \$OWNER
gh repo set-default $ORGANIZATION/$REPOSITORY_NAME
gh pr checkout $PULL_REQUEST_NUMBER

exec fish
EOF

chmod +x $TEMP_SCRIPT

# Run the script in kitty
term-aux -e bash -c "$TEMP_SCRIPT"

