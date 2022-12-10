#!/bin/bash

sslName=$1
filePem=/etc/pki/ssl/$sslName.pem
fileCsr=/etc/pki/ssl/$sslName.csr
fileCrt=/etc/pki/ssl/$sslName.crt

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
