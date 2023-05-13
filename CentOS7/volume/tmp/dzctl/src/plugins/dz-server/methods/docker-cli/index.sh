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

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "检查 Docker"
DockerVersion=$(rpm -qa | grep docker-ce)
[[ ! $DockerVersion ]] && dzLogError "dzctl docker-cli => need docker-ce" && exit
let StageNo+=1

dzLogStage $StageNo "运行 Docker Dashboard Cli"
dzLogInfo "准备镜像"
dzImage dz-server/lazydocker:1.0.0 lazyteam/lazydocker:latest
dzLogInfo "准备 Docker compose file"
DzDcy=/etc/dz/docker-compose/dz-docker-cli/docker-compose.yml
DzEnv=/etc/dz/docker-compose/dz-docker-cli/.env
dzTmpFsPull $DzDcy "TmpFsRemove" && dzTmpFsPush $DzDcy && dzTmpFsPull $DzDcy
dzTmpFsPull $DzEnv "TmpFsRemove" && dzTmpFsPush $DzEnv && dzTmpFsPull $DzEnv
dzLogInfo "开始部署"
docker compose -f $DzDcy run dz-lazydocker
let StageNo+=1
