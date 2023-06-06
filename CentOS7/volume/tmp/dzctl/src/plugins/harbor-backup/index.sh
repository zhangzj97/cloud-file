#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port:, -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
    case $1 in
    --domain)
        Domain=$2 && shift 2
        ;;
    --port)
        Port=$2 && shift 2
        ;;
    --)
        break
        ;;
    *)
        dzLogError "Internal error!" && exit 1
        ;;
    esac
done
if [[ ! $Domain ]]; then
    IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
    dzTmpFsPush $IfcfgPath &&
        StaticIp=$(dzTmpFsMatch $IfcfgPath 's|^.*IPADDR="?([^"]*)"?.*$|\1|g')
    Domain=$StaticIp
fi
# [[ ! $Port ]] && dzLogError "option --port is invalid" && exit 0

###################################################################################################
## 备份
###################################################################################################

BackupServer() {
    Service=$1

    dzLogInfo "备份 => ${Service}"

    dzTarC $ServerPath/backup/dz-$Service-$TimeFlag.bak.tar.gz $ServerPath/dz-$Service
}

###################################################################################################
## 业务
###################################################################################################
StageNo=1

# TODO
ServerPath=/etc/dz-server
DokcerPath=/etc/docker

TimeFlag=$(date "+%Y-%m-%d_%H-%M-%S")
mkdir -p $ServerPath/backup/

dzLogStage $StageNo "备份 SSL"
dzTarC $ServerPath/backup/docker-$TimeFlag.bak.tar.gz $DokcerPath
dzLogStage $StageNo "备份 Server"
BackupServer harbor
let StageNo+=1

sz $ServerPath/backup/dz-harbor-$TimeFlag.bak.tar.gz
