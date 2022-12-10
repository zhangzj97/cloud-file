#!/bin/bash

sslName=$1
filePem=/etc/pki/ssl/$sslName.pem
fileCsr=/etc/pki/ssl/$sslName.csr
fileCrt=/etc/pki/ssl/$sslName.csr

subject=/C=CN/CN=$1

openssl genrsa -out $filePem 2048

openssl req -key $filePem -out $fileCsr -subj $subject -new -days 3650

openssl x509 -in $fileCsr -out $fileCrt

openssl x509 -in $fileCsr -text -noout
