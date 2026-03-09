#!/bin/bash

#
# Review a GitLab merge request using ollama
# Checks out the MR and runs code review on the diff
#

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
MERGE_REQUEST_NUMBER=$(extract_gitlab_mr_number "$URL")

REVIEW_DIR=$(build_review_path "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$MERGE_REQUEST_NUMBER")
MODEL="${OLLAMA_CODE_REVIEW_MODEL:-qwen2.5-coder:7b}"

TEMP_SCRIPT=~/review_mr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

source "$SCRIPT_DIR/git-lib.sh"

REVIEW_DIR="$REVIEW_DIR"
MODEL="$MODEL"

# Check if already checked out
if [ -d "\$REVIEW_DIR" ]; then
    echo "Merge request already checked out at: \$REVIEW_DIR"
    cd "\$REVIEW_DIR"
else
    mkdir -p "\$(dirname "\$REVIEW_DIR")"
    cd "\$(dirname "\$REVIEW_DIR")"
    echo "Checking out merge request: $MERGE_REQUEST_NUMBER into \$REVIEW_DIR..."

    smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$MERGE_REQUEST_NUMBER"

    if [ ! -d "$MERGE_REQUEST_NUMBER" ]; then
        echo "ERROR: Failed to clone repository"
        exec fish
        exit 1
    fi

    cd $MERGE_REQUEST_NUMBER
    glab mr checkout $MERGE_REQUEST_NUMBER
fi

# Download raw diff to project root
DIFF_FILE="mr-$MERGE_REQUEST_NUMBER.diff"
echo "Downloading MR diff..."
glab mr diff $MERGE_REQUEST_NUMBER > "\$DIFF_FILE"
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
