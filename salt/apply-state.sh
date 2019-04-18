#!/bin/bash

# Apply salt states to install pavedroad development environment
# Apply states in masterless mode using salt-call

# for debugging
# showgrains=1
# dryrun="test=True"
# loglevel=debug
loglevel=info

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

salt-call \
    --config-dir "${saltdir}/config/" \
    grains.setval username $(whoami)

salt-call \
    --config-dir "${saltdir}/config/" \
    grains.setval homedir $HOME

salt-call \
    --config-dir "${saltdir}/config/" \
    grains.setval saltenv dev

salt-call \
    --config-dir "${saltdir}/config/" \
    --file-root  "${saltdir}/states/" \
    --log-level  ${loglevel} \
    state.highstate ${dryrun}

if [ ${showgrains} ]; then
    salt-call \
        --config-dir "${saltdir}/config/" \
        grains.items
fi
