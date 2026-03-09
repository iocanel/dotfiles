#!/bin/bash

#
# Review a GitHub pull request using ollama
# Checks out the PR and runs code review on the diff
#

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
PULL_REQUEST_NUMBER=$(extract_github_pr_number "$URL")

REVIEW_DIR=$(build_review_path "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$PULL_REQUEST_NUMBER")
MODEL="${OLLAMA_CODE_REVIEW_MODEL:-qwen2.5-coder:7b}"

TEMP_SCRIPT=~/review_pr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

source "$SCRIPT_DIR/git-lib.sh"

REVIEW_DIR="$REVIEW_DIR"
MODEL="$MODEL"

# Check if already checked out
if [ -d "\$REVIEW_DIR" ]; then
    echo "Pull request already checked out at: \$REVIEW_DIR"
    cd "\$REVIEW_DIR"
else
    mkdir -p "\$(dirname "\$REVIEW_DIR")"
    cd "\$(dirname "\$REVIEW_DIR")"
    echo "Checking out pull request: $PULL_REQUEST_NUMBER into \$REVIEW_DIR..."

    smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$PULL_REQUEST_NUMBER"

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
fi

# Download raw diff to project root
DIFF_FILE="pr-$PULL_REQUEST_NUMBER.diff"
echo "Downloading PR diff..."
gh pr diff $PULL_REQUEST_NUMBER > "\$DIFF_FILE"
echo "Diff saved to: \$DIFF_FILE"

# Run code review with ollama
echo ""
echo "=========================================="
echo "Running code review with \$MODEL..."
echo "=========================================="
echo ""

ollama run "\$MODEL" "Please review the following code diff and provide feedback on:
1. Code quality and best practices
2. Potential bugs or issues
3. Security concerns
4. Suggestions for improvement

Diff:
\$(cat "\$DIFF_FILE")"

exec fish
EOF

chmod +x $TEMP_SCRIPT
term-aux -e bash -c "$TEMP_SCRIPT"
