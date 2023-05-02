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
  --ssl)
    SSL=$2 && shift 2
    ;;
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done
[[ ! $Domain ]] && logErrorResult "option --domain is invalid" && exit 0
[[ ! $Port ]] && logErrorResult "option --port is invalid" && exit 0

StageNo=0

dzLogStage $StageNo "检查 Harbor"
ServerDomainPort=$Domain:$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
[[ ! -f $ServerKey ]] && dzLogError "File $ServerKey is not found" && exit
dzLogInfo "准备 Harbor 安装文件"
DzHarborInstallerFile01=$DZ_VOL_FS_PATH/etc/dz/harbor-installer/install.sh
DzHarborInstallerFile02=$DZ_VOL_FS_PATH/etc/dz/harbor-installer/common.sh
DzHarborInstallerFile03=$DZ_VOL_FS_PATH/etc/dz/harbor-installer/prepare
DzHarborInstallerFile04=$DZ_VOL_FS_PATH/etc/dz/harbor-installer/harbor.yml
dzTmpFsPush $DzHarborInstallerFile01 && dzTmpFsPull $DzHarborInstallerFile01
dzTmpFsPush $DzHarborInstallerFile02 && dzTmpFsPull $DzHarborInstallerFile02
dzTmpFsPush $DzHarborInstallerFile03 && dzTmpFsPull $DzHarborInstallerFile03
dzTmpFsPush $DzHarborInstallerFile04 && dzTmpFsPull $DzHarborInstallerFile04
dzLogInfo "修改 Harbor env"

DzHarborEnv=$DZ_VOL_FS_PATH/etc/dz/harbor-installer/.env
dzTmpFsPush $DzHarborYml &&
  dzTmpFsEdit $DzHarborYml 's|^.*hostname="?([^"]*)"?.*$|hostname=${Domain}|g' &&
  dzTmpFsEdit $DzHarborYml 's|^.*https_port="?([^"]*)"?.*$|https_port=${Port}|g' &&
  dzTmpFsEdit $DzHarborYml 's|^.*https_private_key="?([^"]*)"?.*$|https_private_key=${ServerKey}|g' &&
  dzTmpFsEdit $DzHarborYml 's|^.*https_certificate="?([^"]*)"?.*$|https_certificate=${ServerCert}|g' &&
  dzTmpFsPull $DzHarborYml
source /etc/dz/harbor-installer/install.sh
