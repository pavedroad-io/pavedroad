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

while getopts "b:ds" opt; do
  case ${opt} in
    b ) branch="--branch ${OPTARG}"
      ;;
    d ) debug="-l debug"
      ;;
    s ) chown=false
      ;;
    \? ) echo "Usage: "$0" [-b <branch>] [-d] [-s]"
        echo "-b <branch> - git clone"
        echo "-d          - debug states"
        echo "-s          - skip chown"
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
    echo "Changing owner of directories in /usr/local/bin to" $(whoami)
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
    sudo chown -R $(whoami) ${brewdirs[*]}
    cd ${OLDPWD}
else
    echo "Skipping change owner of directories in /usr/local/bin to" $(whoami)
fi

# Install homebrew
if command -v brew >& /dev/null; then
    echo Homebrew is installed
else
    echo Installing Homebrew
    /usr/bin/ruby -e $(curl -fsSLo /tmp/install.sh https://raw.githubusercontent.com/Homebrew/install/master/install)
fi

# Install developer tools if needed, newer versions of homebrew already do this
if xcode-select --version >& /dev/null; then
    echo Command Line Tools are installed
else
    sw_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
    if [[ "${sw_vers}" -ge 9 ]]; then
        if clt_update=$(softwareupdate -l | grep "\*.*Command Line"); then
            echo Installing update to Command Line Tools
            clt_name=$(echo ${clt_update} | head -n 1 | awk -F"*" '{print $2}')
            clt_pkg=$(echo ${clt_name} | sed -e 's/^ *//' | tr -d '\n')
            clt_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
            touch ${clt_file}
            softwareupdate --install --verbose "${clt_pkg}"
            rm -f ${clt_file}
        else
            echo Update to Command Line Tools not found
        fi
    else
        echo Not updating Command Line Tools for MacOS prior to version 10.9
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
fi
salt-call --version

# Clone salt states
echo Cloning salt states
tmpdir=$(mktemp -d -t kevlar-repo 2>/dev/null)
git clone ${branch} https://github.com/pavedroad-io/kevlar-repo.git ${tmpdir}

# Apply salt states
echo Applying salt states
saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
${tmpdir}/salt/apply-state.sh ${debug}
mv ${tmpdir} ${saltdir}
