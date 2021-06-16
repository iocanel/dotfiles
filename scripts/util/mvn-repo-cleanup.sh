
#!/bin/sh

M2_REPO=${HOME}/.m2
OLDFILES=/tmp/deleted_artifacts.txt
AGE=181 # more or less 6 months and it's a palindromic prime number, so it's cool

echo "==== To be Deleted Jars ====" >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*jar' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}

echo "==== To be Deleted Wars/Ears ====" >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*war' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*ear' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}

echo "==== To be Deleted APKs ====" >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*apk' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*apksources' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}
find "${M2_REPO}" -name '*-SNAPSHOT*apklib' -atime +${AGE} -exec dirname {} \; >> ${OLDFILES}

for x in `cat ${OLDFILES}`; do rm -rf "$x"; done

# Just as final cleanup.
echo "==== Empty Directories ====" >> ${OLDFILES}
find "${M2_REPO}" -type d -empty -exec rmdir {} \; >> ${OLDFILES}

