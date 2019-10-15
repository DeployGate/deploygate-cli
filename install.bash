#!/usr/bin/env bash

set -eu
set -o pipefail

export MIN_RUBY_VERSION="2.4.0"
export DG_DIRECTORY="$HOME/.dg"
export DG_BIN_DIRECTORY_NAME="link"

readonly BOLD="$(tput bold)"
readonly GREEN="$(tput setaf 2)"
readonly RED="$(tput setaf 1)"
readonly MAGENTA="$(tput setaf 5)"
readonly RESET="$(tput sgr0)"
readonly COFFEE="☕️"

warn() {
  echo -e "${RED}$*${RESET}" 1>&2
}

checking() {
  echo -en "- [ ] $*\r"
  sleep 1
}

ok() {
  # enough length
  echo -en "                              \r"
  echo -e "- [${GREEN}\u2714${RESET}] $*"
}

abort() {
  # enough length
  echo -en "                              \r"
  echo -e "- [${RED}\u2573${RESET}] $*"
}

pending() {
  # enough length
  echo -en "                              \r"
  echo -e "- [-] $*"
}

mkdir -p "${DG_DIRECTORY}/${DG_BIN_DIRECTORY_NAME}"

# Change the working directory to know which ruby version being used in the deploygate's directory.
pushd "${DG_DIRECTORY}" >/dev/null

echo "Checking requirements..."

checking "Checking ruby..."

if ! type "ruby" >/dev/null 2>&1; then
  abort 'ruby is not found'
  warn "ruby is required to install dg. Please make sure ruby is installed."
  exit 1
fi

ok "ruby is installed."

checking "Checking ruby's version..."

if ! $(ruby -e "exit 1 unless RUBY_VERSION >= ENV.fetch('MIN_RUBY_VERSION')"); then
  abort "ruby's version is not enough"
  warn "$(ruby --version) is currently running but it has not been supported."
  warn "Please upgrade ruby to ${MIN_RUBY_VERSION} or over."

  exit 1
fi

ok "ruby's version ($(ruby --version)) is enough."

checking "Checking bundler..."

if ! type "bundle" >/dev/null 2>&1; then
  abort "bundle is not found"
  warn "bundle command is required to install dg. Please run ${BOLD}gem install bundler${RESET} to install it."
  exit 1
fi

ok "bundler ($(bundler --version)) is installed."

cat<<EOF

This script will install dg to ${DG_DIRECTORY}/${DG_BIN_DIRECTORY_NAME} ...

EOF

checking "Checking the existing files..."

if ([ -L '/usr/local/bin/dg' ] || [ -f '/usr/local/bin/dg' ]) && [ ! -f 'Gemfile.lock' ]; then
  abort '/usr/local/bin/dg is found but not managed by this script.'
  warn 'It sounds you have installed dg command by another way. Please uninstall the currently installed version to proceed.'
  exit 1
fi

if [ -f "${DG_BIN_DIRECTORY_NAME}/dg" ]; then
  pending 'it sounds dg has already been installed.'
  read -p "Would you like to upgrade dg to the newer version or install dg under the new ruby version? (y/N): " yn

  case "$yn" in
    [yY]*)
      ok 'dg has been installed and will be manipulated'
      ;;
    *)
      warn "Canceled."
      exit 1
      ;;
  esac
else
  ok 'dg has not been installed yet'
fi

cat<<EOF
Installing ${BOLD}dg${RESET}.
${BOLD}This may take a while.${RESET} It's a good time to grab some coffee ${COFFEE}

EOF

sleep 1s

readonly ruby_version="$(ruby -e 'puts RUBY_VERSION')"
readonly ruby_abi=$(echo $ruby_version | cut -d. -f1-2).0

if [ ! -f "Gemfile" ]; then
  bundle init
  echo >> Gemfile; echo "gem 'deploygate'" >> Gemfile
fi

# NOTE: this option is available since bundler 2.x
bundle config --local global_path_appends_ruby_scope true >/dev/null
bundle config --local disable_shared_gems true >/dev/null

bundle check || bundle install --jobs=4 --clean --retry 3 --path=vendor/bundle
bundle update deploygate

cat<<EOS > "${DG_BIN_DIRECTORY_NAME}/dg"
#!/usr/bin/env bash

set -eu
set -o pipefail

if \$(ruby -e "exit 1 unless RUBY_VERSION == '$ruby_version')"); then
  echo 'dg has been installed to $ruby_version but not to \$(ruby --version)' 1>&2
  echo 'Please run "cd $DG_DIRECTORY && bundle install" manually to re-install dg into the current ruby version' 1>&2
  exit 1
fi

if (($(bundle --version | awk '\$0=\$3' | cut -d. -f1) < 2)); then
  export BUNDLE_PATH="$DG_DIRECTORY/vendor/bundle/ruby/$ruby_abi"
else
  export BUNDLE_PATH="$DG_DIRECTORY/vendor/bundle"
fi

export BUNDLE_GEMFILE="$DG_DIRECTORY/Gemfile"
export BUNDLE_GLOBAL_PATH_APPENDS_RUBY_SCOPE=true

exec bundle exec dg "\$@"
EOS

chmod +x "${DG_BIN_DIRECTORY_NAME}/dg"
ln -sf "${DG_DIRECTORY}/${DG_BIN_DIRECTORY_NAME}/dg" /usr/local/bin/dg

echo -e "${GREEN}Welcome to DeployGate!${RESET}"
cat <<'EOF'
        _            _                       _
      | |          | |                     | |
    __| | ___  ___ | | ___ _   ,____   ___ | |_ ___
    / _` |/ _ \' _ \| |/ _ \ \ / / _ \ / _ `| __/ _ \
  | (_| |  __/ |_) | | (_) \ v / (_| | (_| | |_' __/
    \___, \___| .__/|_|\___/ ` / \__, |\__,_|\__\___`
              |_|           /_/  |___/

EOF
fi
