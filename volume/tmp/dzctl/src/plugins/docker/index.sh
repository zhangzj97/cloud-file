#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l xxx: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit
    ;;
  esac
done

StageNo=1

dzLogStage $StageNo "安装 Docker"
dzRpm docker-ce
systemctl enable --now docker
DaemonJson=/etc/docker/daemon.json
dzTmpFsPull $DaemonJson "TmpFsRemove" && dzTmpFsPush $DaemonJson && dzTmpFsPull $DaemonJson
systemctl daemon-reload
systemctl restart docker
let StageNo+=1
