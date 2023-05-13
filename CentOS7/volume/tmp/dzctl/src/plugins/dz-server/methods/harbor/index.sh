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
[[ ! $Domain ]] && dzLogError "option --domain is invalid" && exit 0
[[ ! $Port ]] && dzLogError "option --port is invalid" && exit 0

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "检查 Harbor"
ServerDomainPort=$Domain--$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
CaCrt=/etc/docker/certs.d/ca.crt
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
dzLogInfo "准备 Harbor 安装文件"
DzHarborInstallerFile01=/etc/dz/harbor-installer/install.sh
DzHarborInstallerFile02=/etc/dz/harbor-installer/common.sh
DzHarborInstallerFile03=/etc/dz/harbor-installer/prepare
dzTmpFsPush $DzHarborInstallerFile01 && dzTmpFsPull $DzHarborInstallerFile01
dzTmpFsPush $DzHarborInstallerFile02 && dzTmpFsPull $DzHarborInstallerFile02
dzTmpFsPush $DzHarborInstallerFile03 && dzTmpFsPull $DzHarborInstallerFile03
dzLogInfo "修改 Harbor 初始化 config"
DzHarborYml=/etc/dz/harbor-installer/harbor.yml
DzHarborYml__hostname=$Domain
DzHarborYml__https_port=$Port
DzHarborYml__https_certificate=$ServerCert
DzHarborYml__https_private_key=$ServerKey
DzHarborYml__harbor_admin_password=123123
DzHarborYml__data_volume=/var/lib/docker/volumes/dz-harbor-data
DzHarborYml__log_local_location=/var/log/harbor
dzTmpFsPull $DzHarborYml "TmpFsRemove"
dzTmpFsPush $DzHarborYml &&
  dzTmpFsEdit $DzHarborYml "s|__hostname__|$DzHarborYml__hostname|g" &&
  dzTmpFsEdit $DzHarborYml "s|__https_port__|$DzHarborYml__https_port|g" &&
  dzTmpFsEdit $DzHarborYml "s|__https_certificate__|$DzHarborYml__https_certificate|g" &&
  dzTmpFsEdit $DzHarborYml "s|__https_private_key__|$DzHarborYml__https_private_key|g" &&
  dzTmpFsEdit $DzHarborYml "s|__harbor_admin_password__|$DzHarborYml__harbor_admin_password|g" &&
  dzTmpFsEdit $DzHarborYml "s|__data_volume__|$DzHarborYml__data_volume|g" &&
  dzTmpFsEdit $DzHarborYml "s|__log_local_location__|$DzHarborYml__log_local_location|g" &&
  dzTmpFsPull $DzHarborYml
chmod u+x /etc/dz/harbor-installer/install.sh
chmod u+x /etc/dz/harbor-installer/prepare
/etc/dz/harbor-installer/install.sh
dzLogInfo "[访问] $Domain:$Port"

dzLogInfo ""
dzLogInfo ""
dzLogInfo "TODO 将来用 脚本处理"
dzLogInfo "vim /etc/docker/daemon.json"
dzLogInfo "添加 \"insecure-registries\": [\"192.168.226.100:9005\"],"
dzLogInfo "systemctl restart docker"
dzLogInfo ""
dzLogInfo ""
dzLogInfo ""
