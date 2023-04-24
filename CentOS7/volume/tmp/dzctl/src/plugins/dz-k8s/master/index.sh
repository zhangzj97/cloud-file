#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l a1:,a2: -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    logErrorResult "Internal error!" && exit 1
    ;;
  esac
done

StageNo=0

logStage $StageNo "Deploy as master"
kubeadm init \
  --apiserver-advertise-address=192.168.226.100 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubeadm token create --ttl 0 --print-join-command
kubeadm token list
let StageNo+=1
