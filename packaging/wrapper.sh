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

# Figure out where this script is located.
SELFDIR="`dirname \"$RESULT\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

read INSTALLED_VIA_HOMEBREW < "$RESULT/lib/bundle-env"
export DEPLOYGATE_INSTALLED_VIA_HOMEBREW=$INSTALLED_VIA_HOMEBREW
echo $DEPLOYGATE_INSTALLED_VIA_HOMEBREW

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
exec "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/bin/dg" "$@"
