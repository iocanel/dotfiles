#!/bin/bash

FILE=$1
KEY=$2
VALUE=$3

grep -q "^export $KEY" $FILE && sed -i "s/^export\ $KEY.*/export\ $KEY=$VALUE/" $FILE || echo "export $KEY=$VALUE" >> $FILE

