#!/bin/bash

# TBD trap on error

# for debug
# showgrains=1
# echo=echo
# dryrun="test=True"
# loglevel=debug
loglevel=info

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    grains.setval username $(whoami)

${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    grains.setval homedir $HOME

${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    grains.setval stateroot ${saltdir}/states

${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    grains.setval saltenv dev

${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    --file-root  "${saltdir}/states/" \
    --log-level  $loglevel \
    state.highstate ${dryrun}

if [ $showgrains ]; then
    salt-call                             \
        --config-dir "${saltdir}/config/" \
        --file-root  "${saltdir}/states/" \
        grains.items
fi
