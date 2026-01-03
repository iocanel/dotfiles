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

## Create a script to run in kitty
TEMP_SCRIPT=~/clone_mr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

# Source the git library to use smart_clone
source "$SCRIPT_DIR/git-lib.sh"

TEMP_DIR=\$(mktemp -d)
cd \$TEMP_DIR
echo "Checking out merge request: $MERGE_REQUEST_NUMBER into \$TEMP_DIR/$REPOSITORY_NAME..."

# Use smart_clone instead of hardcoded git clone
smart_clone "$HOST" "$ORGANIZATION" "$REPOSITORY_NAME" "$REPOSITORY_NAME"

# Check if clone was successful
if [ ! -d "$REPOSITORY_NAME" ]; then
    echo "ERROR: Failed to clone repository"
    exec fish
    exit 1
fi

cd $REPOSITORY_NAME
glab mr checkout $MERGE_REQUEST_NUMBER

exec fish
EOF

chmod +x $TEMP_SCRIPT

# Run the script in kitty
kitty --class EditorTerm -e bash -c "$TEMP_SCRIPT"