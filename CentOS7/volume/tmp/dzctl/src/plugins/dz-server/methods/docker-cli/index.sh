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
DzDockerCliDCY=/etc/dz/docker-compose/dz-docker-cli/docker-compose.yml
dzTmpFsPull $DzDockerCliDCY "TmpFsRemove"
dzTmpFsPush $DzDockerCliDCY &&
  dzTmpFsPull $DzDockerCliDCY
dzImage dz-server/lazydocker:1.0.0 lazyteam/lazydocker:latest
docker compose -f $DzDockerCliDCY run dz-lazydocker
let StageNo+=1
