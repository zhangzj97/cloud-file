#!/bin/bash -i

RED='\e[1;31m'    # 红
GREEN='\e[1;32m'  # 绿
YELLOW='\e[1;33m' # 黄
BLUE='\e[1;34m'   # 蓝
PINK='\e[1;35m'   # 粉红
RES='\e[0m'       # 清除颜色

logStage() {
  echo ""
  echo ""
  echo -e "${BLUE}                ============================================================"
  echo -e "${BLUE}                $1 ${RES}"
}

logStep() {
  echo -e "                    $1"
}

logResult() {
  echo -e "${GREEN}                                [RESULT] Finish Stage Successfully! ${RES}"
  echo ""
}

logErrorResult() {
  echo -e "${RED}                    [Error] $1 ${RES}"
  echo ""
}

cpDir() {
  rm -fr $2
  mkdir -p $2
  /bin/cp -fa $1/* $2
}

StageRemark=(
  "[Stage00]"
  "[Stage01] Validate          | Validate param"
)

# Validate | Validate param
logStage "${StageRemark[1]}"
# [[ $* =~ get ]] && echo Error apply && exit

# Certificate | Generate Certificate 
logStage "${StageRemark[2]}"
DzCertsdPath=/etc/dz/certs.d
TargetCertsdPath=$DzCertsdPath/localhost
# Generate a Certificate Authority Certificate
logStep "[Certificate] Config path"
mkdir -p $DzCertsdPath
mkdir -p $TargetCertsdPath
CaKeyPath=$DzCertsdPath/ca.key
CaCrtPath=$DzCertsdPath/ca.crt
logStep "[Certificate] Generate a Certificate Authority Certificate"
openssl genrsa -out $CaKeyPath 4096
openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top" -key $CaKeyPath -out $CaCrtPath
# Generate a Generate a Server Certificate
logStep "[Certificate] Generate a Generate a Server Certificate"
TargetKeyPath=$TargetCertsdPath/localhost.key
TargetCsrPath=$TargetCertsdPath/localhost.csr
TargetCrtPath=$TargetCertsdPath/localhost.crt
TargetCertPath=$TargetCertsdPath/localhost.cert
openssl genrsa -out $TargetKeyPath 4096
openssl req -sha512 -new -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=zhangzejie.top" -key $TargetKeyPath  -out $TargetCsrPath
# Generate an x509 v3 extension file
logStep "[Certificate] Generate an x509 v3 extension file"
V3ExtPath=$TargetCertsdPath/v3.ext
/bin/cp -fa /tmp/cloud-file-git/CentOS7_All_001/volume/etc/dz/certs.d/v3.ext $V3ExtPath
openssl x509 -req -sha512 -days 3650 -extfile $V3ExtPath -CA $CaCrtPath -CAkey $CaKeyPath -CAcreateserial -in $TargetCsrPath -out $TargetCrtPath
openssl x509 -inform PEM -in $TargetCrtPath -out $TargetCertPath
# Copy dir
cpDir $TargetCertsdPath /etc/docker/certs.d/localhost
systemctl restart docker
