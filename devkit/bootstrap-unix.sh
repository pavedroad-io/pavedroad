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
chown=1
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
    c ) chown=
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

# set default install type and name
install_type="bootstrap"
install_name="salt"
os_identity="Unknown OS"
os_version="unknown"
ubuntu_install=

if command -v salt-call >& /dev/null; then
    # salt is already installed
    install_type="none"
elif test -e "${os_rel_file}" ; then
    # later ubuntu versions only support package manager installs
    source "${os_rel_file}"
    os_identity=${ID}
    os_version=${VERSION_ID}
    if [[ "${ID}" == "${ubuntu_identity}" ]] ; then
        ubuntu_install=1
        if [[ " ${ubuntu_versions[*]} " == *"${VERSION_ID}"* ]] ; then
            install_type="apt-get"
            install_name="salt-common"
        fi
    fi
fi
echo Bootstrapping on ${os_identity} version ${os_version}

# Install git and either curl or pip as needed to install saltstack
# Not a comprehensive list of package managers

if command -v dnf >& /dev/null; then
    echo Using package manager dnf
    if [ ${sudo} ]; then
        ${sudo} -l dnf >& /dev/null
        if [ $? -ne 0 ]; then
            User $(id -un) unable to execute dnf
            exit 1
        fi
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} dnf -y -q install curl
    [ "${install_type}" == "pip" ] && ${sudo} dnf -y -q install python3-pip
    [ ! ${salt_only} ] && ${sudo} dnf -y -q install git
elif command -v yum >& /dev/null; then
    echo Using package manager yum
    if [ ${sudo} ]; then
        ${sudo} -l yum >& /dev/null
        if [ $? -ne 0 ]; then
            User $(id -un) unable to execute yum
            exit 1
        fi
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} yum -y -q install curl
    [ "${install_type}" == "pip" ] && ${sudo} yum -y -q install python3-pip
    [ ! ${salt_only} ] && ${sudo} yum -y -q install git
elif command -v zypper >& /dev/null; then
    echo Using package manager zypper
    bootstrap_version="stable"
    if [ ${sudo} ]; then
        ${sudo} -l zypper >& /dev/null
        if [ $? -ne 0 ]; then
            User $(id -un) unable to execute zypper
            exit 1
        fi
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} zypper -q install -y curl
    [ "${install_type}" == "pip" ] && ${sudo} zypper -q install -y python3-pip
    [ ! ${salt_only} ] && ${sudo} zypper -q install -y git
elif command -v apt-get >& /dev/null; then
    echo Using package manager apt-get
    if [ ${sudo} ]; then
        ${sudo} -l apt-get >& /dev/null
        if [ $? -ne 0 ]; then
            User $(id -un) unable to execute apt-get
            exit 1
        fi
    fi
    ${sudo} apt-get -qq update >& /dev/null
    if [ $? -ne 0 ]; then
        echo ${os_identity} version ${os_version} is not supported
        exit 1
    fi
    [ "${install_type}" == "bootstrap" ] && ${sudo} apt-get -y -qq install curl
    [ "${install_type}" == "pip" ] && ${sudo} apt-get -qq install -y python3-pip
    [ ! ${salt_only} ] && ${sudo} apt-get -y -qq install git
else
    echo Supported package manager not found
    exit 1
fi

# Command exit value checking not needed from this point
trap 'error_trap' ERR
set -o errexit -o errtrace

# Install saltstack
if [ "${install_type}" == "none" ]; then
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
