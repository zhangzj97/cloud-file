#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l domain:,port: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --domain)
    Domain=$2
    shift 2
    ;;
  --port)
    Port=$2
    shift 2
    ;;
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!"
    exit 1
    ;;
  esac
done
[[ ! $Domain ]] && logErrorResult "option --domain is invalid" && exit 0
[[ ! $Port ]] && logErrorResult "option --port is invalid" && exit 0

StageNo=0

logStage $StageNo "Check Certificate Authority"
ServerDomainPort=$Domain:$Port
[[ ! $ServerDomainPort ]] && echo "Need doamin and port" && exit 0
DzCertsdPath=/etc/dz/certs.d
ServerCertsdPath=$DzCertsdPath/$ServerDomainPort
CaKeyPath=$DzCertsdPath/ca.key
CaCrtPath=$DzCertsdPath/ca.crt
if [[ ! -f $CaKeyPath ]]; then
  logStep "[Certificate] Generate CA Certificate"
  logStep "${Space04}===> ${DzCertsdPath}"
  mkdir -p $DzCertsdPath
  openssl genrsa -out $CaKeyPath 4096
  CaSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
  openssl req -x509 -new -nodes -sha512 -days 3650 -subj $CaSubj -key $CaKeyPath -out $CaCrtPath
fi
let StageNo+=1

logStage $StageNo "Generate a Server Certificate"
ServerKeyPath=$ServerCertsdPath/server.key
ServerCsrPath=$ServerCertsdPath/server.csr
ServerCrtPath=$ServerCertsdPath/server.crt
ServerCertPath=$ServerCertsdPath/server.cert
[[ -f $ServerKeyPath ]] && logErrorResult "Doamin exists" && exit 0
logStep "[Certificate] Generate Server key"
logStep "${Space04}===> ${ServerCertsdPath}"
mkdir -p $ServerCertsdPath
openssl genrsa -out $ServerKeyPath 4096
ServerSubj="/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top"
openssl req -sha512 -new -subj $ServerSubj -key $ServerKeyPath -out $ServerCsrPath
# Generate an x509 v3 extension file
logStep "[Certificate] Generate an x509 v3 extension file"
V3ExtPath=$ServerCertsdPath/v3.ext
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/etc/dz/certs.d/v3.ext $V3ExtPath
openssl x509 -req -sha512 -days 3650 -extfile $V3ExtPath -CA $CaCrtPath -CAkey $CaKeyPath -CAcreateserial -in $ServerCsrPath -out $ServerCrtPath
openssl x509 -inform PEM -in $ServerCrtPath -out $ServerCertPath
logStep "[Certificate] Copy file"
logStep "${Space04}===> /etc/docker/certs.d/${ServerDomainPort}"
cpDir $DzCertsdPath/$ServerDomainPort /etc/docker/certs.d/$ServerDomainPort
let StageNo+=1

logStage $StageNo "Restart Service"
systemctl restart docker
