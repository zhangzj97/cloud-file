#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port: -n 'dzctl' -- "$@")
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
    dzLogError "Internal error!" && exit
    ;;
  esac
done
[[ ! $Domain ]] && dzLogError "option --domain is invalid" && exit
[[ ! $Port ]] && dzLogError "option --port is invalid" && exit

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "Certificate Authority"
CaKey=/etc/docker/certs.d/ca.key
CaCrt=/etc/docker/certs.d/ca.crt
if [[ ! -f $CaKey ]]; then
  dzLogInfo "[Certificate] Generate CA Certificate"
  dzTmpFsPush $CaKey &&
    dzTmpFsPull $CaKey
  CaSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
  openssl genrsa -out $CaKey 4096
  openssl req -x509 -new -nodes -sha512 -days 3650 -subj $CaSubj -key $CaKey -out $CaCrt
fi
let StageNo+=1

dzLogStage $StageNo "Server Certificate"
ServerDomainPort=$Domain:$Port
ServerKey=/etc/docker/certs.d/$ServerDomainPort/server.key
ServerCsr=/etc/docker/certs.d/$ServerDomainPort/server.csr
ServerCrt=/etc/docker/certs.d/$ServerDomainPort/server.crt
ServerCert=/etc/docker/certs.d/$ServerDomainPort/server.cert
[[ -f $ServerKey ]] && dzLogError "Doamin exists" && exit
dzLogInfo "[Certificate] Generate Server key"
dzTmpFsPush $ServerKey &&
  dzTmpFsPull $ServerKey
ServerSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
openssl genrsa -out $ServerKey 4096
openssl req -sha512 -new -subj $ServerSubj -key $ServerKey -out $ServerCsr
dzLogInfo "[Certificate] Generate an x509 v3 extension file"
V3Ext=/etc/docker/certs.d/v3.ext
dzTmpFsPush $V3Ext &&
  dzTmpFsPull $V3Ext
openssl x509 -req -sha512 -days 3650 -extfile $V3Ext -CA $CaCrt -CAkey $CaKey -CAcreateserial -in $ServerCsr -out $ServerCrt
openssl x509 -inform PEM -in $ServerCrt -out $ServerCert
let StageNo+=1
