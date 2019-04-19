#!/usr/bin/env bash

# Bootstrap saltstack on Unix

sudo=$(command -v sudo >& /dev/null)

# Setting must be after above sudo check which can fail
set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

# Not a comprehensive check
if [ -e "/etc/lsb-release" ]; then
    echo OS family is Debian
    ${sudo} apt-get -qq update
    ${sudo} apt-get -qq -y install curl
    ${sudo} apt-get -qq -y install git
elif [ -e "/etc/redhat-release" ]; then
    echo OS family is RedHat
    ${sudo} yum -q -y install curl
    ${sudo} yum -q -y install git
elif [ -e "/etc/SuSE-release" ]; then
    echo OS family is SuSE
    ${sudo} zypper -q install -y curl
    ${sudo} zypper -q install -y git
else
    echo OS family is not supported
    exit 1
fi

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

# Install saltstack
curl -o install_salt.sh -L https://bootstrap.saltstack.com

# -P Prevent failure by allowing the script to use pip as a dependency source
# -X Do not start minion service with
${sudo} sh install_salt.sh -P -X

# Get salt states
tmp=$(mktemp -d -t kevlar-repo.XXXXXX 2>/dev/null)
# git clone https://github.com/pavedroad-io/kevlar-repo.git ${tmp}
# Temporarily clone from salt-init branch
git clone -b salt-init https://github.com/pavedroad-io/kevlar-repo.git ${tmp}

# Apply salt states
${tmp}/salt/apply-state.sh
mv ${tmp} ${saltdir}
