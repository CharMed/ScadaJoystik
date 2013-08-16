#/usr/bin/env bash

git status > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    echo "Must run in repository!!" >&2
    return 1
fi


DIST=$(git rev-parse --show-toplevel)
OUT_DIR="${DIST}/../dist/"
echo "Out dir: $OUT_DIR"

if [ ! -d $OUT_DIR ]
then
    mkdir $OUT_DIR
fi

REF=""

if [ ! "$1" != "" ]
then
    LAST_TAG_NAME=$( git for-each-ref --sort='*authordate' --format='%(refname:short)' refs/tags | tail -n 1 )
    REF=$LAST_TAG_NAME
else
    REF=$1
fi

TMPDIR=$(mktemp -d)

echo "Build $REF ..."

git archive --format=tar --output="$TMPDIR/dist.tar" $REF
if [ $? -ne 0 ] ; then
    echo "Error! Failed creating archive" >&2
    rm -rf $TMPDIR
    return 2
fi

./scripts/version.sh > "${TMPDIR}/VERSION"

tar rf "$TMPDIR/dist.tar" -C "${TMPDIR}" "VERSION" 
gzip -c "$TMPDIR/dist.tar" > "${OUT_DIR}/dist_${REF}.tar.gz"

du -hs "${OUT_DIR}/dist_${REF}.tar.gz"

rm -rf $TMPDIR

