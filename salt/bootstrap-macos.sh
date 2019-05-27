#!/usr/bin/env bash

# Bootstrap saltstack on MacOS

branch=

while getopts "b:" opt; do
  case ${opt} in
    b ) branch="--branch ${OPTARG}"
      ;;
    \? ) echo "Usage: "$0" [-b <branch>]"
        exit 1
      ;;
  esac
done

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

# Script only runs on macOS
case "$OSTYPE" in
  darwin*)
    echo OS family is MacOS
    ;;
  *)
    echo OS family is not supported
    exit 1
    ;;
esac

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

# Install developer tools
xcode-select --install

# Prepare /usr/local for homebrew
brewdirs=(Caskroom Cellar Frameworks Homebrew bin doc etc include lib libexec opt sbin share var)
cd /usr/local
sudo mkdir -p -m 0755 ${brewdirs}
sudo chown -R $(whoami) ${brewdirs}
cd

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install saltstack
brew install saltstack
salt-call --version

# Get salt states
tmp=$(mktemp -d -t kevlar-repo.XXXXXX 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/kevlar-repo.git ${tmp}

# Apply salt states
${tmp}/salt/apply-state.sh
mv ${tmp} ${saltdir}
