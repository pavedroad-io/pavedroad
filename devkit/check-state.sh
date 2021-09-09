#!/usr/bin/env bash

# Apply and debug specific pavedroad devkit salt states
# Apply states in masterless mode using salt-call

usage_top() {
    echo "[Usage: $(basename $0) <options> <log option> state]"
}

usage_options() {
cat << EOF
Valid options:
-f force color
-h help with usage
-l list log options
-n script dry run
-u upgrade mode
-C command
-D clear cache
-F state file
-G set grains
-H highstate
-N states dry run
-O <output>
-P show pillar
-R render
-S show grains
-T show <type>
-V <verbose>
-X <execute>
EOF
}

log_options() {
cat << EOF
Valid log options:
-a all
-c critical
-d debug
-e error
-g garbage
-i info
-p profile
-q quiet
-t trace
-w warning
EOF
}

output_values="full terse mixed changes filter"
usage_output() {
    echo "Valid output values are:"
    echo ${output_values}
}

verbose_values="True False"
usage_verbose() {
    echo "Valid verbose values are:"
    echo ${verbose_values}
}

saltdir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)

salt_top=${saltdir}/states
usage_state() {
    echo Valid state values are:
    echo $(ls $salt_top | grep -v top.* | tr '\n' ' ')
}

dryrun=
forcecolor=
highstate=
clearcache=
nostate=
loglevel=
output=
testsalt=
setgrains=
showgrains=
showpillar=
showtype=
render=
state=
verbose=
saltargs=
saltrun="install"

while getopts ":acdefgipqtwC:DF:GHNO:PRST:V:X:hlnu" opt; do
  case ${opt} in
    a ) loglevel="--log-level=all"
      ;;
    c ) loglevel="--log-level=critical"
      ;;
    d ) loglevel="--log-level=debug"
      ;;
    e ) loglevel="--log-level=error"
      ;;
    g ) loglevel="--log-level=garbage"
      ;;
    i ) loglevel="--log-level=info"
      ;;
    p ) loglevel="--log-level=profile"
      ;;
    q ) loglevel="--log-level=quiet"
      ;;
    t ) loglevel="--log-level=trace"
      ;;
    w ) loglevel="--log-level=warning"
      ;;
    C ) command="${OPTARG}"
      ;;
    D ) clearcache=1
        nostate=1
      ;;
    F ) file="${OPTARG}"
        nostate=1
      ;;
    G ) setgrains=1
      ;;
    H ) highstate=1
      ;;
    N ) testsalt="test=True"
      ;;
    O ) output="${OPTARG}"
      ;;
    P ) showpillar=1
        nostate=1
      ;;
    R ) render=1
      ;;
    S ) showgrains=1
        nostate=1
      ;;
    T ) showtype="${OPTARG}"
        nostate=1
      ;;
    V ) verbose="${OPTARG}"
      ;;
    X ) saltargs="${OPTARG}"
      ;;
    f ) forcecolor="--force-color"
      ;;
    h ) usage_top
        usage_options
        log_options
        usage_output
        usage_verbose
        usage_state
        exit 0
      ;;
    l ) log_options
        exit 0
      ;;
    n ) dryrun=1
      ;;
    u ) saltrun="upgrade"
      ;;
    : )
        echo Argument required: $OPTARG 1>&2
        usage_top
        usage_options
        log_options
        exit 1
      ;;
    \? )
        echo Invalid option: $OPTARG 1>&2
        usage_top
        usage_options
        log_options
        exit 1
      ;;
  esac
done

output_error=
if [ ${output} ]; then
    echo ${output_values} | grep -w ${output} >& /dev/null
    if [[ $? -ne 0 ]]; then
        output_error="[Invalid <output> value: ${output}]"
    fi
    output="--state-output=${output}"
fi

verbose_error=
if [ ${verbose} ]; then
    echo ${verbose_values} | grep -w ${verbose} >& /dev/null
    if [[ $? -ne 0 ]]; then
        verbose_error="[Invalid <verbose> value: ${verbose}]"
    fi
    verbose="--state-verbose=${verbose}"
fi

shift $((OPTIND - 1))
state_error=
if [[ ${saltargs} ]]; then
    echo execute: salt-call ${saltargs}
elif [[ ${nostate} ]]; then
    if [[ ${state} ]]; then
        echo Ignoring state: ${state}
    fi
elif [[ $# -eq 1 ]]; then
    state="$*"
    # ls -1 $salt_top | grep -v top.* | grep -w ${state} >& /dev/null
    ls -1 $salt_top | grep -v top.* | grep ${state} >& /dev/null
    if [[ $? -ne 0 ]]; then
        state_error="[Invalid state value: ${state}]"
    fi
elif [[ $# -eq 0 ]]; then
    state_error="[No state supplied]"
else
    state_error="[Multiple states supplied: $*]"
fi

if [[ ${output_error} || ${verbose_error} || ${state_error} ]]; then
    usage_top
    usage_options
    if [[ ${output_error} ]]; then
        echo
        echo ${output_error}
        usage_output
    fi
    if [[ ${verbose_error} ]]; then
        echo
        echo ${verbose_error}
        usage_verbose
    fi
    if [[ ${state_error} ]]; then
        echo
        echo ${state_error}
        usage_state
    fi
    exit 1
fi

if [[ ! ${command} ]]; then
    if [[ ${file} ]]; then
        file="${saltdir}/states/${file}"
    elif [[ ${state} ]]; then
        file="${saltdir}/states/${state}/init.sls"
    fi
fi

if [[ ${saltargs} ]]; then
    execute=${saltargs}
elif [[ ${clearcache} ]]; then
    execute="saltutil.clear_cache"
elif [[ ${command} ]]; then
    execute="${command} ${file}"
elif [[ ${render} ]]; then
    execute="slsutil.renderer ${file}"
elif [[ ${showgrains} ]]; then
    execute="grains.items"
elif [[ ${showpillar} ]]; then
    execute="pillar.items"
elif [[ ${showtype} ]]; then
    execute="state.show_${showtype} --output=yaml ${file}"
elif [[ ${highstate} ]]; then
    execute="state.highstate ${testsalt}"
else
    execute="state.apply ${state} ${testsalt}"
fi

if [ ${dryrun} ]; then
    if [[ ${loglevel} || ${output} || ${verbose} ]]; then
        echo Options: ${loglevel} ${output} ${verbose}
    fi
    echo Command: ${execute}
    exit 0
fi

set -o errexit -o errtrace

function error_trap
{
  local code="$?"
  local command="${BASH_COMMAND:-unknown}"
  echo "command [${command}] exited with code [${code}]" 1>&2
}
trap 'error_trap' ERR

export PYTHONWARNINGS=ignore

if [ ${setgrains} ]; then

    if (cat /proc/1/cgroup | grep docker) >& /dev/null ; then
        docker=True
    else
        docker=False
    fi

    declare -A grains
    grains[realuser]="$(id -un ${SUDO_UID})"
    grains[realgroup]="$(id -gn ${SUDO_UID})"
    grains[homedir]="$(eval echo ~$(id -un ${SUDO_UID}))"
    grains[saltenv]=dev
    grains[saltrun]="${saltrun}"
    grains[docker]="${docker}"

    for key in "${!grains[@]}"; do
        salt-call \
            --config-dir "${saltdir}/config/" \
            grains.setval ${key} "${grains[${key}]}"
    done
fi

salt-call \
    --config-dir  "${saltdir}/config/" \
    --pillar-root "${saltdir}/pillar/" \
    --file-root   "${saltdir}/states/" \
    ${loglevel} ${output} ${verbose} \
    ${forcecolor} ${execute}
