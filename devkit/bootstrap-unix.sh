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

# Get correct user/group/home in case script is run using sudo
# For example when provisioning vm using vagrant
if [ ${SUDO_UID} ] ; then
    bootuser=$(id -un ${SUDO_UID})
    bootgroup=$(id -gn ${SUDO_UID})
    boothome=$(eval echo ~$(id -un ${SUDO_UID}))
    if [ ${sudo} ] ; then
        usersudo="${sudo} -u ${bootuser}"
    fi
else
    bootuser=$(id -un)
    bootgroup=$(id -gn)
    boothome=$(eval echo ~$(id -un))
fi

branch=
chown=1
debug=
salt_only=

os_rel_file="/etc/os-release"
centos_identity="centos"
fedora_identity="fedora"
opensuse_identity="opensuse-leap"
ubuntu_identity="ubuntu"

function usage
{
    echo "Usage: "$0" [-b <branch>] [-c] [-d] [-h] [-s]"
    echo "-b <branch> - branch to use for git clone"
    echo "-c          - chown command will be skipped"
    echo "-d          - debug mode set on salt states"
    echo "-h          - help by showing this usage"
    echo "-s          - salt only will be installed"
}

while getopts ":b:cdhs" opt; do
  case ${opt} in
    b ) branch="--branch ${OPTARG}"
        echo Using git branch ${OPTARG}
      ;;
    c ) chown=
        echo Skipping chown to user
      ;;
    d ) debug="-l debug"
        echo Setting debug salt mode
      ;;
    h ) usage
        exit 0
      ;;
    s ) salt_only=1
        echo Installing salt only
      ;;
    : )
        echo Argument required: $OPTARG 1>&2
        usage
        exit 1
      ;;
    \? )
        echo Invalid option: $OPTARG 1>&2
        usage
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

# Set default OS identity and version
os_identity="Unknown OS"
os_version="unknown"
if test -e "${os_rel_file}" ; then
    source "${os_rel_file}"
    os_identity=${ID}
    os_version=${VERSION_ID}
fi
echo Bootstrapping on: ${os_identity} version: ${os_version}

# Set default salt install type and name
install_type="bootstrap"
install_name="salt"

# Set salt install version for each supported OS versions
ubuntu_3000_versions=( 16.04 18.04 )
ubuntu_3001_versions=( 20.04 )
centos_3000_versions=( 7 8 )
fedora_3000_versions=( 30 31 )
fedora_3001_versions=( 32 )
opensuse_ignore_versions=( 15.1 15.2 )

if command -v salt-call >& /dev/null; then
    # salt is already installed
    install_type="none"
elif [[ "${os_identity}" == "${ubuntu_identity}" ]] ; then
    # ubuntu version 19.10 requires package manager install
    if [[ " ${ubuntu_aptget_versions[*]} " == *"${os_version}"* ]] ; then
        install_type="apt-get"
        install_name="salt-common"
    elif [[ " ${ubuntu_3000_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version="3000"
    elif [[ " ${ubuntu_3001_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version="3001"
    else
        echo ${os_identity} version ${os_version} is not supported
        exit 1
    fi
elif [[ "${os_identity}" == "${centos_identity}" ]] ; then
    if [[ " ${centos_3000_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version="3000"
    else
        echo ${os_identity} version ${os_version} is not supported
        exit 1
    fi
elif [[ "${os_identity}" == "${fedora_identity}" ]] ; then
    if [[ " ${fedora_3000_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version="3000"
    elif [[ " ${fedora_3001_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version="3001"
    else
        echo ${os_identity} version ${os_version} is not supported
        exit 1
    fi
elif [[ "${os_identity}" == "${opensuse_identity}" ]] ; then
    # openSUSE does not accept specific version for salt bootstrap
    # Workaround for https://github.com/saltstack/salt/issues/53570
    if [[ " ${opensuse_ignore_versions[*]} " == *"${os_version}"* ]] ; then
        salt_version=""
    else
        echo ${os_identity} version ${os_version} is not supported
        exit 1
    fi
fi

if [[ "${install_type}" == "bootstrap" ]] ; then
    bootstrap_version="stable ${salt_version}"
fi

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
else
    echo -n Installing SaltStack with ${install_type}:
    if [ "${install_type}" == "apt-get" ]; then
        echo ${install_name}
        ${sudo} apt-get -y -qq install ${install_name}
    elif [ "${install_type}" == "bootstrap" ]; then
        echo ${bootstrap_version}
        curl -o install_salt.sh -L https://bootstrap.saltstack.com
        # -d Disable checking if Salt services are enabled to start on system boot
        # -P Prevent failure by allowing the script to use pip as a dependency source
        # -X Do not start minion service
        ${sudo} sh install_salt.sh -d -P -X ${bootstrap_version}
    elif [ "${install_type}" == "pip" ]; then
        echo ${salt_version}
        ${sudo} pip3 install ${install_name}==${salt_version}
    fi
    echo SaltStack ${install_type} installation complete
fi

echo -n "Version: "
salt-call --version

if [ ${salt_only} ] ; then
    echo Not installing the development kit
    exit
fi

# Clone salt states
echo Cloning the development kit repository
tmpdir=$(mktemp -d -t pavedroad.XXXXXX 2>/dev/null)
rm -rf ${tmpdir}
${usersudo} git clone ${branch} https://github.com/pavedroad-io/pavedroad.git ${tmpdir}

# Apply salt states
echo Installing the development kit
${usersudo} ${sudo} ${tmpdir}/devkit/apply-state.sh ${debug}
${sudo} mv ${tmpdir} ${boothome}
${sudo} mv pr-root ${boothome}/$(basename ${tmpdir})/devkit

# Temporary fix until permanent fix TBD in salt states
if [ ${chown} ] ; then
    ${sudo} chown -R ${bootuser}:${bootgroup} ${boothome}
fi
echo Development kit installation complete

if [ ${DISPLAY} ] && command -v xdg-open >& /dev/null; then
    echo Opening the getting started page for the development kit
    export BROWSER=/usr/bin/firefox
    xdg-open https://www.pavedroad.io/learning-center/
fi
