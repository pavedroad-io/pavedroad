#!/usr/bin/env bash

# Bootstrap saltstack on MacOS

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
  darwin*) ;;
  *) echo "OS is not macOS, exiting"; exit 1 ;;
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

# Apply salt states
${saltdir}/apply-state.sh
