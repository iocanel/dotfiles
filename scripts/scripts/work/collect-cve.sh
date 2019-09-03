#!/bin/bash

TARGET=$1

if [ ! -f "$TARGET" ]; then
   echo "|id|cve|component|description|bugzilla link|jira link|comments|" > $TARGET
   echo "|-" >> $TARGET
fi

mu find from:bugzilla and subject:CVE | awk -F '[ :\\]\\[]' '{print $13}' | sort | uniq | while read id; do

# Skip ids that already exist
EXISTS=`cat $TARGET | grep "$id"`
if [ -n "$EXISTS" ]; then
   continue
fi

# Get the line and remove: `New:` and `EMBARGOED` occurances.
STR=`mu find from:bugzilla and subject:CVE | grep $id  | sed -e 's/New: //g' | sed -e 's/EMBARGOED //g' | head -n 1`

CVE=`echo $STR | awk -F '[ :\\\]\\\[]' '{print $15}'`
COMPONENT=`echo $STR | awk -F '[ :\\\]\\\[]' '{print $16}'`
DESCRIPTION=`echo $STR | awk -F '[ :\\\]\\\[]' '{for(i=17;i<=NF;i++){printf "%s ", $i}; printf "\n"}'`
BUGZILLA_LINK="https://bugzilla.redhat.com/show_bug.cgi?id=$id"
echo "|$id|$CVE|$COMPONENT|$DESCRIPTION|$BUGZILLA_LINK|||" >> $TARGET
done
