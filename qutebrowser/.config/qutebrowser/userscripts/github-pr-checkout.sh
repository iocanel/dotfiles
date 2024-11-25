#!/bin/bash

# 
# Checkout a Github pull request for review
# Determine the ssh URL of the repository the specified URL (first argument) belongs to.
# cd in t
# 

URL=$1
ORGANIZATION=$(echo $URL | sed -n 's/.*github.com\/\([^\/]*\)\/.*/\1/p')
REPOSITORY_NAME=$(echo $URL | sed -n 's/.*github.com\/[^\/]*\/\([^\/]*\).*/\1/p')
CLONE_URL_SSH="git@github.com:$ORGANIZATION/$REPOSITORY_NAME.git"
PROJECT_PATH=~/workspace/src/github.com/$ORGANIZATION/$REPOSITORY_NAME
PULL_REQUEST_NUMBER=$(echo $URL | sed -n 's/.*pull\/\([0-9]*\).*/\1/p')
# Determine the remote name and branch from the pull request number
if [ ! -d $PROJECT_PATH ]; then
  mkdir -p ~/workspace/src/github.com/$ORGANIZATION
  cd ~/workspace/src/github.com/$ORGANIZATION
  git clone $CLONE_URL_SSH
fi

## Create a script to run in kitty
TEMP_SCRIPT=~/clone_pr.sh
cat <<EOF > $TEMP_SCRIPT
#!/bin/bash

TEMP_DIR=$(mktemp -d)
cd \$TEMP_DIR
echo "Checking out pull request: $PULL_REQUEST_NUMBER into \$TEMP_DIR/$REPOSITORY_NAME..."
git clone -n $CLONE_URL_SSH
cd $REPOSITORY_NAME
OWNER=\$(gh pr view --json headRepositoryOwner -q .headRepositoryOwner.login $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_NAME=\$(gh pr view --json headRepository -q .headRepository.name $PULL_REQUEST_NUMBER)
OWNER_REPOSITORY_URL="git@github.com:\$OWNER/\$OWNER_REPOSITORY_NAME.git"
git remote add \$OWNER \$OWNER_REPOSITORY_URL
git fetch \$OWNER
gh pr checkout $PULL_REQUEST_NUMBER

exec fish
EOF

chmod +x $TEMP_SCRIPT

# Run the script in kitty
kitty --class EditorTerm -e bash -c "$TEMP_SCRIPT"

