#!/bin/bash

# 
# Checkout a GitLab merge request for review
# Determine the ssh URL of the repository the specified URL (first argument) belongs to.
# cd in t
# 

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/git-lib.sh"

URL=$1
HOST=$(extract_host "$URL")
ORGANIZATION=$(extract_organization "$URL")
REPOSITORY_NAME=$(extract_repository "$URL")
MERGE_REQUEST_NUMBER=$(extract_gitlab_mr_number "$URL")

REVIEW_DIR=$(build_review_path "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$MERGE_REQUEST_NUMBER")

# Create a script to run in terminal
TEMP_SCRIPT=~/clone_mr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

REVIEW_DIR="$REVIEW_DIR"

# Check if already checked out
if [ -d "\$REVIEW_DIR" ]; then
    echo "Merge request already checked out at: \$REVIEW_DIR"
    cd "\$REVIEW_DIR"
    exec fish
fi

# Create parent directory
mkdir -p "\$(dirname "\$REVIEW_DIR")"
cd "\$(dirname "\$REVIEW_DIR")"
echo "Checking out merge request: $MERGE_REQUEST_NUMBER into \$REVIEW_DIR..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$MERGE_REQUEST_NUMBER"

# Check if clone was successful
if [ ! -d "$MERGE_REQUEST_NUMBER" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $MERGE_REQUEST_NUMBER
glab mr checkout $MERGE_REQUEST_NUMBER

exec fish
EOF

chmod +x $TEMP_SCRIPT

# Run the script in terminal
term-aux -e bash -c "$TEMP_SCRIPT"
