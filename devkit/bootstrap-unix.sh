#!/usr/bin/env bash

# Bootstrap saltstack on Unix, clone salt states and apply them
# Must be run by user with correct sudo permissions
# Password prompt will occur if needed to verify user sudo permission

sudo=$(command -v sudo)
if [ $? -eq 0 ]; then
    sudo -v
    if [ $? -ne 0 ]; then
        echo User $(id -un) does not have sudo permission
        exit 1
    fi
fi

branch=
chown=true
debug=
salt_only=

# Fixing salt version at "stable 2019.2.0" for all systems
#   except openSUSE which will only accept "stable" for the version
# Workaround for https://github.com/saltstack/salt/issues/53570
salt_version="2019.2.0"
bootstrap_version="stable ${salt_version}"

# Salt bootstrap fails for newer Ubuntu versions thus apt-get install is used
# In this case the installed salt version is the package manager latest
os_rel_file="/etc/os-release"
ubuntu_identity="ubuntu"
ubuntu_versions=(
19.10
)

while getopts "b:ds" opt; do
  case ${opt} in
    b ) branch="--branch ${OPTARG}"
        echo Using git branch ${OPTARG}
      ;;
    c ) chown=false
        echo Skipping chown to $USER
      ;;
    d ) debug="-l debug"
        echo Setting debug mode
      ;;
    s ) salt_only=1
        echo Installing salt only
      ;;
    \? ) echo "Usage: "$0" [-b <branch>] [-c] [-d] [-s]"
        echo "-b <branch> - git clone"
        echo "-c          - chown skip"
        echo "-d          - debug states"
        echo "-s          - salt only"
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

# set default install type and name
install_type="bootstrap"
install_name="salt"

# Later ubuntu versions fail with bootstrap and pip installs
if test -e "${os_rel_file}" ; then
    source "${os_rel_file}"
    if [[ "${ID}" == "${ubuntu_identity}" ]] ; then
        if [[ " ${ubuntu_versions[*]} " == *"${VERSION_ID}"* ]] ; then
            install_type="apt-get"
            install_name="salt-common"
        fi
    fi
fi

# Install git and either curl or pip as needed to install saltstack
# Not a comprehensive list of package managers

if command -v dnf >& /dev/null; then
    echo Using package manager dnf
    ${sudo} dnf history info >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(id -un) unable to execute dnf
        exit 1
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} dnf -y -q install curl
    [ "${install_type}" == "pip" ] && ${sudo} dnf -y -q install python3-pip
    ${sudo} dnf -y -q install git
elif command -v yum >& /dev/null; then
    echo Using package manager yum
    ${sudo} yum history info >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(id -un) unable to execute yum
        exit 1
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} yum -y -q install curl
    [ "${install_type}" == "pip" ] && ${sudo} yum -y -q install python3-pip
    ${sudo} yum -y -q install git
elif command -v zypper >& /dev/null; then
    echo Using package manager zypper
    bootstrap_version="stable"
    ${sudo} zypper refresh >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(id -un) unable to execute zypper
        exit 1
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} zypper -q install -y curl
    [ "${install_type}" == "pip" ] && ${sudo} zypper -q install -y python3-pip
    ${sudo} zypper -q install -y git
elif command -v apt-get >& /dev/null; then
    echo Using package manager apt-get
    ${sudo} apt-get -qq update >& /dev/null
    if [ $? -ne 0 ]; then
        echo User $(id -un) unable to execute apt-get
        exit 1
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} apt-get -y -qq install curl
    [ "${install_type}" == "pip" ] && ${sudo} apt-get -qq install -y python3-pip
    ${sudo} apt-get -y -qq install git
else
    echo Supported package manager not found
    exit 1
fi

# Command exit value checking not needed from this point
set -o errexit -o errtrace

# Install saltstack
if command -v salt-call >& /dev/null; then
    echo SaltStack is already installed
elif [ "${install_type}" == "apt-get" ]; then
    echo Installing SaltStack with apt-get
    ${sudo} apt-get -y -qq install ${install_name}
    echo SaltStack apt-get installation complete
elif [ "${install_type}" == "bootstrap" ]; then
    echo Installing SaltStack with bootstrap
    curl -o install_salt.sh -L https://bootstrap.saltstack.com
    # -P Prevent failure by allowing the script to use pip as a dependency source
    # -X Do not start minion service
    ${sudo} sh install_salt.sh -P -X ${bootstrap_version}
    echo SaltStack bootstrap installation complete
elif [ "${install_type}" == "pip" ]; then
    echo Installing SaltStack with pip
    ${sudo} pip3 install ${install_name}==${salt_version}
    echo SaltStack pip installation complete
fi

echo -n "Version: "
salt-call --version

if [ ${salt_only} ] ; then
    echo Not installing the devlopment kit
    exit
fi

# Clone salt states
echo Cloning the devlopment kit repository
tmpdir=$(mktemp -d -t pavedroad.XXXXXX 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/pavedroad.git ${tmpdir}

# Apply salt states
echo Installing the devlopment kit
saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
${sudo} ${tmpdir}/devkit/apply-state.sh ${debug}
mv ${tmpdir} ${saltdir}

# Temporary fix until permanent fix TBD in salt states
if ${chown}; then
    homedir=$(eval echo ~$(id -un))
    ${sudo} chown -R $(id -un):$(id -gn) ${homedir}
fi
echo Development kit installation complete

if command -v xdg-open >& /dev/null; then
    echo Opening the getting started page for the devlopment kit
    xdg-open http://www.pavedroad.io/Tooling.html
fi
