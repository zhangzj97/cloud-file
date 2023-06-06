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
## 业务
###################################################################################################
StageNo=1

# TODO
ServerPath=/etc/dz-server
DokcerPath=/etc/docker

let StageNo+=1
