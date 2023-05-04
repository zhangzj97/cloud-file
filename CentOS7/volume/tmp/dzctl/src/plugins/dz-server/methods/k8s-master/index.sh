#!/bin/bash -i

source $DZ_TOOL_PATH

ARGS=$(getopt -l xxx:,xxx2:, -n 'dzctl' -- "$@")
[ $? != 0 ] && echo Erro options && exit
eval set -- "${ARGS}"
while true; do
  case $1 in
  --)
    break
    ;;
  *)
    dzLogError "Internal error!" && exit 1
    ;;
  esac
done

StageNo=1

dzLogStage $StageNo "下载国内源镜像 images"
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
let StageNo+=1

dzLogStage $StageNo "初始化 k8s"
dzLogInfo "获取网络信息"
IfcfgPath=/etc/sysconfig/network-scripts/ifcfg-ens33
StaticIp=$(dzTmpFsMatch $IfcfgPath 's|^.*IPADDR="?([^"]*)"?.*$|\1|g')
kubeadm init \
  --apiserver-advertise-address=$StaticIp \
  --pod-network-cidr=10.224.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --cri-socket unix:///var/run/cri-dockerd.sock
mkdir -p $HOME/.kube
/bin/cp -fa /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubeadm token create --print-join-command
kubeadm token list
let StageNo+=1

dzLogStage $StageNo "初始化 k8s 网络配置"
KubeFlannelYml=/etc/dz/k8s/kube-flannel.yml
dzTmpFsPush $KubeFlannelYml &&
  dzTmpFsPull $KubeFlannelYml
kubectl apply -f /tmp/kube-flannel.yml
let StageNo+=1
