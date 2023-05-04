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

StageNo=1

logStage $StageNo "Deploy as master"
# kubeadm init \
#   --apiserver-advertise-address=192.168.226.100 \
#   --pod-network-cidr=10.224.0.0/16 \
#   --service-cidr=10.96.0.0/12 \
#   --cri-socket unix:///var/run/cri.docker.sock
# mkdir -p $HOME/.kube
# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# chown $(id -u):$(id -g) $HOME/.kube/config
# kubeadm token create --ttl 0 --print-join-command
# kubeadm token list

kubeadm config images list
images=(
  kube-apiserver:v1.27.1
  kube-controller-manager:v1.27.1
  kube-scheduler:v1.27.1
  kube-proxy:v1.27.1
  pause:3.9
  etcd:3.5.7-0
  # coredns/coredns:1.10.1
)
for imageName in ${images[@]}; do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName registry.k8s.io/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
docker pull coredns/coredns:1.10.1
docker tag coredns/coredns:1.10.1 registry.k8s.io/coredns/coredns:v1.10.1
docker rmi coredns/coredns:1.10.1

docker images

# kubeadm config print init-defaults > /tmp/kubeadm-init.yaml
# kubeadm config images pull --config=/tmp/kubeadm-init.yaml
kubeadm init \
  --apiserver-advertise-address=192.168.226.100 \
  --pod-network-cidr=10.224.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --cri-socket unix:///var/run/cri-dockerd.sock
mkdir -p $HOME/.kube
/bin/cp -fa /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubeadm token create --print-join-command
kubeadm token list
# kubeadm init --config kubeadm-init.yaml | tee kubeadm-init.log
# kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock
dzWget /tmp/kube-flannel.yml https://raw.fastgit.org/coreos/flannel/master/Documentation/kube-flannel.yml && logFile /tmp/kube-flannel.yml
kubectl apply -f /tmp/kube-flannel.yml

let StageNo+=1
