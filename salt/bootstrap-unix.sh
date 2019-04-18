#!/usr/bin/env bash

# Bootstrap saltstack on Unix

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

# Not a comprehensive check
case "$OSTYPE" in
  darwin* | win*) echo "OS is not supported, exiting"; exit 1 ;;
  *) ;;
esac

# Install missing developer tools
# Assuming curl is installed

# Install saltstack
curl -o install_salt.sh -L https://bootstrap.saltstack.com

# Prevent failure with -P flag so that the script can use pip as a dependency source
sudo sh install_salt.sh -P

# Get salt states
git clone https://github.com/pavedroad-io/kevlar-repo.git

# Apply salt states
kevlar-repo/salt/apply-state.sh
