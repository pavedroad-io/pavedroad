#!/usr/bin/env bash

# Bootstrap saltstack on MacOS, clone salt states and apply them
# Cannot be run as root, newer versions of homebrew will not run as root
# Changing directory ownership in /usr/local/bin for homebrew requires sudo
# The sudo chown command can be skipped with the -s option
# Password prompt will occur only if the owner change is not skipped

if [ $(id -u) = 0 ]; then
   echo Command cannot be run as root
   exit 1
fi

branch=
chown=true
debug=
salt_only=

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
    c ) chown=false
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
trap 'error_trap' ERR

# Script only runs on macOS
case "$OSTYPE" in
  darwin*)
    sw_vers
    ;;
  *)
    echo OS family is not supported
    exit 1
    ;;
esac

# Prepare /usr/local/bin as homebrew no longer runs under sudo

if ${chown}; then
    echo "Changing owner of directories in /usr/local/bin to" $(id -un)
    brewdirs=(
        Caskroom
        Cellar
        Homebrew
        Frameworks
        bin
        doc
        etc
        etc/bash_completion.d
        include
        lib
        lib/pkgconfig
        libexec
        opt
        sbin
        share
        share/doc
        share/info
        share/man
        share/man/man1
        share/man/man3
        share/man/man5
        share/man/man8
        share/zsh
        share/zsh/site-functions
        var
        var/homebrew
        var/homebrew/linked
        var/homebrew/locks
    )
    cd /usr/local
    sudo mkdir -p -m 0755 ${brewdirs[*]}
    sudo chown -R $(id -un):$(id -gn) ${brewdirs[*]}
    cd ${OLDPWD}
else
    echo "Skipping change owner of directories in /usr/local/bin to" $(id -un)
fi

# Install homebrew
if command -v brew >& /dev/null; then
    echo Homebrew is installed
else
    echo Installing Homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install developer tools if needed, newer versions of homebrew already do this
if xcode-select -p >& /dev/null; then
    echo Command Line Tools are installed
else
    sw_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
    if [[ "${sw_vers}" -ge 9 ]]; then
        # Temporary file causes softwareupdate to list the Command Line Tools
        clt_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
        touch "${clt_file}"
        if clt_update=$(softwareupdate -l | grep "\*.*Command Line"); then
            echo Installing update to Command Line Tools
            clt_pkg=$(echo "${clt_update}" | head -n 1 | awk -F"* " '{print $2}')
            if ! softwareupdate --install --verbose "${clt_pkg}" ; then
                echo Install of Command Line Tools failed
                echo Try running command "xcode-select --install" before running this script
                exit
            fi
        else
            echo Update to Command Line Tools not found
            echo Try running command "xcode-select --install" before running this script
            exit
        fi
        rm -f "${clt_file}"
    else
        echo Not installing Command Line Tools for MacOS prior to version 10.9
        echo Try running command "xcode-select --install" before running this script
        exit
    fi
fi

# Command exit value checking not needed from this point
set -o errexit -o errtrace

# Install saltstack
if command -v salt-call >& /dev/null; then
    echo SaltStack is installed
else
    echo Installing SaltStack
    brew install saltstack
    echo SaltStack installation complete
fi
echo -n "Version: "
salt-call --version

if [ ${salt_only} ] ; then
    echo Not installing the devlopment kit
    exit
fi

# Clone salt states
echo Cloning the devlopment kit repository
tmpdir=$(mktemp -d -t pavedroad 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/pavedroad.git ${tmpdir}

# Apply salt states
echo Installing the devlopment kit
saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
${tmpdir}/devkit/apply-state.sh ${debug}
mv ${tmpdir} ${saltdir}
echo Development kit installation complete

echo Opening the getting started page for the devlopment kit
open https://www.pavedroad.io/learning-center/
