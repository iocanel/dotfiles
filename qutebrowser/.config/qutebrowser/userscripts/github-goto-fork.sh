#!/bin/bash

#
# Go to the same path of the forked repository
# 
URL=$1
ORGANIZATION=$(echo $URL | sed -n 's/.*github.com\/\([^\/]*\)\/.*/\1/p')
REPOSITORY_NAME=$(echo $URL | sed -n 's/.*github.com\/[^\/]*\/\([^\/]*\).*/\1/p')
PATH=$(echo $URL | sed -n 's/.*github.com\/[^\/]*\/[^\/]*\(\/.*\)/\1/p')

# substitute organization with 'iocanel'
FORK_URL="https://github.com/iocanel/$REPOSITORY_NAME$PATH"
echo "open -t $FORK_URL" >> $QUTE_FIFO
