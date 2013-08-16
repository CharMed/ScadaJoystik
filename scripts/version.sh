#/usr/bin/env bash

git status > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    return 1
fi

LAST_TAG_REF=$( git for-each-ref --sort='*authordate' --format='%(refname:short) %(objectname)' refs/tags | tail -n 1 )

LAST_TAG_REV_HASH=$( echo $LAST_TAG_REF | awk '{print $2;}' )
LAST_TAG_NAME=$( echo $LAST_TAG_REF | awk '{print $1;}' )
LAST_TAG_HASH=$( git rev-list ${LAST_TAG_NAME} | head -1 )
LAST_HASH=$(git log -1 --pretty="%H")

if [ ! ${LAST_HASH} != ${LAST_TAG_HASH} ]
then
    VERSION=$LAST_TAG_NAME
    HASH=$LAST_TAG_REV_HASH
else
    VERSION="${LAST_TAG_NAME}+dev"
    HASH=$LAST_HASH
fi

echo "version $VERSION"
echo "build $HASH"
