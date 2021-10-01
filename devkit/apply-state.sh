#!/usr/bin/env bash

# Apply salt states to install pavedroad development environment
# Apply states in masterless mode using salt-call

showgrains=
loglevel=
dryrun=
output=
verbose=
saltrun="install"

function usage
{
    echo "Usage: "$0" [-g] [-h] [-n] [-u] [-l <loglevel>] [-o <output>] [-v <verbose>]"
    echo "-g            - show grains.items"
    echo "-h            - show usage help"
    echo "-n            - perform dry run"
    echo "-u            - set upgrade mode"
    echo "-l <loglevel> - set --log-level"
    echo "-o <output>   - set --state-output"
    echo "-v <verbose>  - set --state-verbose"
}

while getopts ":ghl:no:uv:" opt; do
  case ${opt} in
    g ) showgrains=1
      ;;
    h ) usage
        exit 0
      ;;
    l ) loglevel="--log-level=${OPTARG}"
      ;;
    n ) dryrun="test=True"
      ;;
    o ) output="--state-output=${OPTARG}"
      ;;
    u ) saltrun="upgrade"
      ;;
    v ) verbose="--state-verbose=${OPTARG}"
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

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

export PYTHONWARNINGS="ignore::DeprecationWarning"

saltdir=$(cd "$(dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

if (cat /proc/1/cgroup | grep docker) >& /dev/null ; then
    docker=True
else
    docker=False
fi

# associative arrays not available in bash before version 4
# thus reverting from associative array to two parallel arrays
grain_names=(
realuser
realgroup
homedir
saltenv
saltrun
docker
)

grain_values=(
"$(id -un ${SUDO_UID})"
"$(id -gn ${SUDO_UID})"
"$(eval echo ~$(id -un ${SUDO_UID}))"
dev
"${saltrun}"
"${docker}"
)

grains_message() {
cat << EOF

Configuring grains for the development kit salt states
EOF
}

states_message() {
cat << EOF

Applying salt states for the development kit now
Please be patient as this process may take 10 to 15 minutes
To see progress: tail -f pr-root/var/log/salt/minion
EOF
}

ignore_message() {
cat << EOF
Running salt in masterless mode
Generally the following message types can be ignored:
    [INFO    ] Routine salt information messages
    [WARNING ] Typically python deprecation warnings
    [ERROR   ] Spurious salt errors unless state fails

EOF
}

grains_message
ignore_message
for i in ${!grain_names[@]}; do
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.setval "${grain_names[$i]}" "${grain_values[$i]}"
done

states_message
ignore_message
salt-call \
    --config-dir "${saltdir}/config/" \
    --pillar-root  "${saltdir}/pillar/" \
    --file-root  "${saltdir}/states/" \
    ${loglevel} ${output} ${verbose} \
    state.highstate ${dryrun} 2>/dev/null

if [ ${showgrains} ]; then
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.items
fi
