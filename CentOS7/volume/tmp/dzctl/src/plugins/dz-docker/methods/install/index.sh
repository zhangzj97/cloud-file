#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -n 'dzctl' -- "$@")
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

StageNo=1

logStage $StageNo "Install Docker"
dzYum docker-ce
systemctl enable --now docker
if [[ -f /etc/docker/daemon.json ]]; then
  /bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/docker/daemon.json /etc/docker/daemon.json &&
    systemctl daemon-reload &&
    systemctl restart docker &&
    logFile /etc/docker/daemon.json
fi
let logStage+=1
