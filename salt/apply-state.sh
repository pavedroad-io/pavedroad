#!/bin/bash

# TBD trap on error

# for debugging
# showgrains=1
# dryrun="test=True"
# loglevel=debug
loglevel=info

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
