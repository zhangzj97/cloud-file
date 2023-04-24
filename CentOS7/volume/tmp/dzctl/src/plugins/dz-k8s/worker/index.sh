#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l a1:,a2: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
    case $1 in
    --)
        break
        ;;
    *)
        logErrorResult "Internal error!" && exit 1
        ;;
    esac
done

StageNo=0

logStage $StageNo "First Stage Description"
let StageNo+=1
