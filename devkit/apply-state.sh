#!/usr/bin/env bash

# Apply salt states to install pavedroad development environment
# Apply states in masterless mode using salt-call

showgrains=
loglevel=
dryrun=
output=
verbose=

while getopts "gl:no:v:" opt; do
  case ${opt} in
    g ) showgrains=1
      ;;
    l ) loglevel="--log-level=${OPTARG}"
      ;;
    n ) dryrun="test=True"
      ;;
    o ) output="--state-output=${OPTARG}"
      ;;
    v ) verbose="--state-verbose=${OPTARG}"
      ;;
    \? ) echo "Usage: "$0" [-g] [-n] [-l <loglevel>] [-o <output>] [-v <verbose>]"
        echo "-g            - show grains.items"
        echo "-l <loglevel> - set --log-level"
        echo "-n            - perform dry run"
        echo "-o <output>   - set --state-output"
        echo "-v <verbose>  - set --state-verbose"
        exit 1
      ;;
  esac
done

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

export PYTHONWARNINGS=ignore

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

if (cat /proc/1/cgroup | grep docker) >& /dev/null ; then
    docker=True
else
    docker=False
fi

if ! test -z "${GOPATH}"; then
    gopath=$(echo ${GOPATH} | awk -F ":" '{print $1}')
else
    gopath=NONE
fi

if ! test -z "${GOROOT}"; then
    goroot="${GOROOT}"
else
    goroot=NONE
fi

declare -A grains
grains[realuser]="$(id -un ${SUDO_UID})"
grains[realgroup]="$(id -gn ${SUDO_UID})"
grains[homedir]="$(eval echo ~$(id -un ${SUDO_UID}))"
grains[stateroot]="${saltdir}/states"
grains[saltenv]=dev
grains[docker]="${docker}"
grains[gopath]="${gopath}"
grains[goroot]="${goroot}"

for key in "${!grains[@]}"; do
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.setval ${key} "${grains[${key}]}"
done

salt-call \
    --config-dir "${saltdir}/config/" \
    --file-root  "${saltdir}/states/" \
    ${loglevel} ${output} ${verbose} \
    state.highstate ${dryrun}

if [ ${showgrains} ]; then
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.items
fi