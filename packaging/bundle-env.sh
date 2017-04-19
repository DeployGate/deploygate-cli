#!/bin/bash

export DEPLOYGATE_INSTALLED_VIA_HOMEBREW={{IS_INSTALLED_VIA_HOMEBREW}}

TARGET_FILE=`basename $0`
SELFDIR="`dirname \"$TARGET_FILE\"`"

export BUNDLE_GEMFILE="$SELFDIR/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

exec "$SELFDIR/ruby/bin/ruby" -rbundler/setup "$@"
