#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l xxx:,xxx2:, -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit 1
    ;;
  esac
done

StageNo=1

dzLogStage $StageNo "准备 K3s"
DzK3sConfigYml=/etc/rancher/k3s/config.yml
dzTmpFsPush $DzK3sConfigYml &&
  dzTmpFsPull $DzK3sConfigYml
curl -sfL http://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC=server sh -
let StageNo+=1
