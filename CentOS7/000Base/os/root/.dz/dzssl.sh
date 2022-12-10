#!/bin/bash

sslName=$1
filePem=/etc/pki/ssl/$sslName.pem
fileCsr=/etc/pki/ssl/$sslName.csr
fileCrt=/etc/pki/ssl/$sslName.crt
fileP12=/etc/pki/ssl/$sslName.p12
fileJks=/etc/pki/ssl/$sslName.jks

subject=/C=CN/CN=$1

if [ ! $sslName ]; then
    echo ""
    echo "[Error]: Param sslName is invalid"
    echo ""
    exit
fi

mkdir -p /etc/pki/ssl/

openssl genrsa -out $filePem 2048

openssl req -key $filePem -out $fileCsr -subj $subject -new -days 3650

openssl x509 -req -in $fileCsr -signkey $filePem -out $fileCrt

openssl x509 -in $fileCsr -text -noout

openssl pkcs12 -export -in $fileCrt -inkey $filePem -out $fileP12 -passout 'pass:123456' -name $sslName

keytool -importkeystore -srckeystore $fileP12 \
    -srcstorepass '123456' -srcstoretype PKCS12 \
    -srcalias $sslName -deststoretype JKS \
    -destkeystore $fileJks -deststorepass '123456' \
    -destalias $sslName
