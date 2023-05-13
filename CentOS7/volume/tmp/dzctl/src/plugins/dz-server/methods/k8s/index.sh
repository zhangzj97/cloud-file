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

###################################################################################################
## 业务
###################################################################################################

StageNo=1

dzLogStage $StageNo "安装准备软件"
dzRpm kubeadm &&
  dzRpm kubelet &&
  dzRpm kubectl
dzRpm ipset
dzRpm ipvsadm
let StageNo+=1

dzLogStage $StageNo "安装 cri-docker"
dzRpm cri-docker https://fastgit.org/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd-0.3.1-3.el7.x86_64.rpm
systemctl enable --now cri-docker
let StageNo+=1

dzLogStage $StageNo "修改 cri-docker 服务配置"
CriDockerService=/usr/lib/systemd/system/cri-docker.service
CriDockerSocket=/usr/lib/systemd/system/cri-docker.socket
dzTmpFsPull $CriDockerService "TmpFsRemove"
dzTmpFsPull $CriDockerSocket "TmpFsRemove"
dzTmpFsPush $CriDockerService &&
  # dzTmpFsEdit $CriDockerService "s|ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://|ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9 --container-runtime-endpoint fd://|g" &&
  dzTmpFsPull $CriDockerService
dzTmpFsPush $CriDockerSocket &&
  dzTmpFsPull $CriDockerSocket
systemctl daemon-reload
systemctl restart cri-docker
let StageNo+=1

dzLogStage $StageNo "修改 网桥 配置"
KubernetesConf=/etc/sysctl.d/kubernetes.conf
dzTmpFsPush $KubernetesConf &&
  dzTmpFsPull $KubernetesConf
dzLogInfo "加载网桥过滤模块 查看方式 lsmod | grep br_netfilter"
sysctl -p
modprobe br_netfilter
let StageNo+=1

dzLogStage $StageNo "修改 ipvs 配置"
IpvsModules=/etc/sysconfig/modules/ipvs.modules
dzTmpFsPush $IpvsModules &&
  dzTmpFsPull $IpvsModules
dzLogInfo "查看方式 lsmod | grep -e ip_vs -e nf_conntrack_ipv4"
chmod u+x $IpvsModules
source $IpvsModules
let StageNo+=1

dzLogStage $StageNo "修改 kubelet 配置"
dzLogInfo "kubelet"
SysconfigKubelet=/etc/sysconfig/kubelet
dzTmpFsPull $SysconfigKubelet "TmpFsRemove"
dzTmpFsPush $SysconfigKubelet &&
  dzTmpFsPull $SysconfigKubelet
ContainerdConfig=/etc/containerd/config.toml
systemctl enable --now kubelet
dzLogInfo "containerd"
dzTmpFsPush $ContainerdConfig &&
  dzTmpFsEdit $ContainerdConfig "/disabled_plugins/s/^(.*)$/# \1/g" &&
  dzTmpFsPull $ContainerdConfig
systemctl restart containerd
let StageNo+=1

dzLogStage $StageNo "修改 Service"
dzLogInfo "chronyd"
systemctl enable --now chronyd
dzLogInfo "firewalld"
systemctl stop firewalld
systemctl disable firewalld
dzLogInfo "iptables"
systemctl stop iptables
systemctl disable iptables
dzLogInfo "selinux"
SysconfigSelinux=/etc/sysconfig/selinux
sed -i --follow-symlinks 's|SELINUX=enforcing|SELINUX=disabled|g' $SysconfigSelinux
setenforce 0
dzLogInfo "swap"
Fstab=/etc/fstab
dzTmpFsPush $Fstab &&
  dzTmpFsEdit $Fstab "/ swap /s/^(.*)$/# \1/g" &&
  dzTmpFsPull $Fstab
swapoff -a
dzLogInfo "k8s"
systemctl restart kubelet
let StageNo+=1

dzLogStage $StageNo "下载国内源镜像 images"
kubeadm config images list
images=(
  kube-apiserver:v1.27.1
  kube-controller-manager:v1.27.1
  kube-scheduler:v1.27.1
  kube-proxy:v1.27.1
  pause:3.9
  etcd:3.5.7-0
  # coredns/coredns:v1.10.1
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
