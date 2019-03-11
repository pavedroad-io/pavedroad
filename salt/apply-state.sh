#!/bin/bash

# TBD trap on error

# for debug
echo=echo
dryrun="test=True"

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

echo=
dryrun=
${echo} salt-call                       \
    --config-dir "${saltdir}/config/" \
    --file-root  "${saltdir}/states/" \
    --log-level  debug \
    state.highstate ${dryrun}
