#!/usr/bin/env bash

# Bootstrap saltstack on Unix, clone salt states and apply them
# Must be run by user with correct sudo permissions
# Password prompt will occur if needed to verify user sudo permission

sudo=$(command -v sudo)
if [ $? -eq 0 ]; then
    sudo -v
    if [ $? -ne 0 ]; then
        echo User $(whoami) does not have sudo permission
        exit 1
    fi
fi

branch=
debug=

# Sets salt install-type to either "stable" or "stable <$salt-version>"
# Workaround for https://github.com/saltstack/salt/issues/53570
salt_version="2019.2.0"
if [ $salt_version ]; then
    install_type="stable ${salt_version}"
else
    install_type="stable"
fi

while getopts "b:d" opt; do
  case ${opt} in
    b ) branch="--branch ${OPTARG}"
      ;;
    d ) debug="-l debug"
      ;;
    \? ) echo "Usage: "$0" [-b <branch>] [-d]"
        echo "-b <branch> - git clone"
        echo "-d          - debug states"
        exit 1
      ;;
  esac
done

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

# Install curl and git, needed to install saltstack
# Not a comprehensive list of package managers

if command -v apt-get >& /dev/null; then
    echo Using package manager apt-get
    ${sudo} apt-get -qq update >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(whoami) unable to execute apt-get
        exit 1
    fi
    ${sudo} apt-get -y -qq install curl git
elif command -v dnf >& /dev/null; then
    echo Using package manager dnf
    ${sudo} dnf history info >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(whoami) unable to execute dnf
        exit 1
    fi
    ${sudo} dnf -y -q install curl git
elif command -v yum >& /dev/null; then
    echo Using package manager yum
    ${sudo} yum history info >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(whoami) unable to execute yum
        exit 1
    fi
    ${sudo} yum -y -q install curl git
elif command -v zypper >& /dev/null; then
    echo Using package manager zypper
    ${sudo} zypper refresh >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(whoami) unable to execute zypper
        exit 1
    fi
    ${sudo} zypper -q install -y curl git
else
    echo Supported package manager not found
    exit 1
fi

# Command exit value checking not needed from this point
set -o errexit -o errtrace

# Install saltstack
if command -v salt-call >& /dev/null; then
    echo SaltStack is installed
else
    echo Installing SaltStack
    curl -o install_salt.sh -L https://bootstrap.saltstack.com

    # -P Prevent failure by allowing the script to use pip as a dependency source
    # -X Do not start minion service
    ${sudo} sh install_salt.sh -P -X ${install_type}
    echo SaltStack installation complete
fi
salt-call --version

# Clone salt states
echo Cloning the devlopment kit repository
tmpdir=$(mktemp -d -t pavedroad.XXXXXX 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/pavedroad.git ${tmpdir}

# Apply salt states
echo Installing the devlopment kit
saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
${sudo} ${tmpdir}/devkit/apply-state.sh ${debug}
mv ${tmpdir} ${saltdir}
# Temporary fix for demo, permanent fix TBD in salt states
${sudo} chown -R $USER:$USER $HOME
echo Development kit installation complete

if command -v xdp-open >& /dev/null; then
    echo Opening the getting started page for the devlopment kit
    xdp-open http://www.pavedroad.io/Tooling.html
fi
