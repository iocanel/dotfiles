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

if [ -z "$PULL_REQUEST_NUMBER" ]; then
    echo "No pull request number found in URL: $URL — falling back to regular clone."
    exec "$SCRIPT_DIR/github-clone.sh" "$URL"
fi

REVIEW_DIR=$(build_review_path "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$PULL_REQUEST_NUMBER")

# Create a script to run in terminal
TEMP_SCRIPT=~/clone_pr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

REVIEW_DIR="$REVIEW_DIR"

# Check if already checked out
if [ -d "\$REVIEW_DIR" ]; then
    echo "Pull request already checked out at: \$REVIEW_DIR"
    cd "\$REVIEW_DIR"
    exec fish
fi

# Create parent directory
mkdir -p "\$(dirname "\$REVIEW_DIR")"
cd "\$(dirname "\$REVIEW_DIR")"
echo "Checking out pull request: $PULL_REQUEST_NUMBER into \$REVIEW_DIR..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$PULL_REQUEST_NUMBER"

# Check if clone was successful
if [ ! -d "$PULL_REQUEST_NUMBER" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $PULL_REQUEST_NUMBER
OWNER=\$(gh pr view --json headRepositoryOwner -q .headRepositoryOwner.login $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_NAME=\$(gh pr view --json headRepository -q .headRepository.name $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_URL="git@github.com:\$OWNER/\$OWNER_REPOSITORY_NAME.git"
git remote add \$OWNER \$OWNER_REPOSITORY_URL
git fetch \$OWNER
gh repo set-default $ORGANIZATION/$REPOSITORY_NAME
gh pr checkout $PULL_REQUEST_NUMBER

# Download raw diff to project root
echo "Downloading PR diff..."
gh pr diff $PULL_REQUEST_NUMBER > pr-$PULL_REQUEST_NUMBER.diff
echo "Diff saved to: pr-$PULL_REQUEST_NUMBER.diff"

exec fish
EOF

chmod +x $TEMP_SCRIPT

# Run the script in terminal
term-aux -e bash -c "$TEMP_SCRIPT"

