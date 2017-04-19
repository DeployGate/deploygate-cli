#!/bin/bash

DEPLOYGATE_DIR="$HOME/.deploygate/"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
  echo "./install [-b]"
  echo "    -b : Installed via homebrew"
  exit 1
}

INSTALLED_VIA_HOMEBREW=false

while getopts ":pub" opt; do
  case $opt in
    b ) INSTALLED_VIA_HOMEBREW=true;;
    * ) usage ;;
  esac
done

BUNDLE_ENV_PATH="$CURRENT_DIR/lib/bundle-env"
sed -i -e "s/{{IS_INSTALLED_VIA_HOMEBREW}}/$INSTALLED_VIA_HOMEBREW/g" $BUNDLE_ENV_PATH

if ! $INSTALLED_VIA_HOMEBREW; then
  echo "Installing deploygate to $DEPLOYGATE_DIR"
  mkdir -p $DEPLOYGATE_DIR
  cp -rf "$CURRENT_DIR/lib" $DEPLOYGATE_DIR
  cp "$CURRENT_DIR/dg" $DEPLOYGATE_DIR
  echo 'Finish install'
fi
