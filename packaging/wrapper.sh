#!/bin/bash
set -e

cd `dirname $0`
TARGET_FILE=`basename $0`

while [ -L "$TARGET_FILE" ]
do
  TARGET_FILE=`readlink $TARGET_FILE`
  cd `dirname $TARGET_FILE`
  TARGET_FILE=`basename $TARGET_FILE`
done

PHYS_DIR=`pwd -P`
RESULT=$PHYS_DIR/$TARGET_FILE

SELFDIR="`dirname \"$RESULT\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

exec "$SELFDIR/lib/bundle-env.sh" "$SELFDIR/lib/app/bin/dg" "$@"
