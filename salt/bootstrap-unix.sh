#!/usr/bin/env bash

# Bootstrap saltstack on Unix

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

sudo=$(command -v sudo)

# Setting must be after above sudo check which can fail
set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

# Not a comprehensive list of package managers
if command -v apt-get >& /dev/null; then
    echo Using package manager apt-get for OS family Debian
    ${sudo} apt-get -qq update
    ${sudo} apt-get -y -qq install curl git
elif command -v dnf >& /dev/null; then
    echo Using package manager dnf for OS family RedHat
    ${sudo} dnf -y -q install curl git
elif command -v yum >& /dev/null; then
    echo Using package manager yum for OS family RedHat
    ${sudo} yum -y -q install curl git
elif command -v zypper >& /dev/null; then
    echo Using package manager zypper for OS family SuSE
    ${sudo} zypper -q install -y curl git
else
    echo Supported package manager not found
    exit 1
fi

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

# Install saltstack
curl -o install_salt.sh -L https://bootstrap.saltstack.com

# -P Prevent failure by allowing the script to use pip as a dependency source
# -X Do not start minion service
${sudo} sh install_salt.sh -P -X
salt-call --version

# Get salt states
tmp=$(mktemp -d -t kevlar-repo.XXXXXX 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/kevlar-repo.git ${tmp}

# Apply salt states
${tmp}/salt/apply-state.sh
mv ${tmp} ${saltdir}
