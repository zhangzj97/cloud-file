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

logStage $StageNo "Config Kubernetes DNS"
dzTextRemove /etc/hosts "K8S" &&
  dzTextAppend /etc/hosts "# <Dz> K8S" &&
  dzTextAppend /etc/hosts "192.168.226.100 master0" &&
  dzTextAppend /etc/hosts "192.168.226.201 master1" &&
  dzTextAppend /etc/hosts "192.168.226.202 master2" &&
  dzTextAppend /etc/hosts "192.168.226.211 worker1" &&
  dzTextAppend /etc/hosts "192.168.226.212 worker2" &&
  dzTextAppend /etc/hosts "# </Dz> K8S" &&
  logFile /etc/hosts
let StageNo+=1

logStage $StageNo "Install Kubernetes and some softwares"
logStep "Checking Package kubeadm" && dzYum kubeadm
logStep "Checking Package kubelet" && dzYum kubelet
logStep "Checking Package kubectl" && dzYum kubectl
logStep "Checking Package ipset  " && dzYum ipset
logStep "Checking Package ipvsadm" && dzYum ipvsadm
let StageNo+=1

logStage $StageNo "Install Cri-docker"
[[ ! -f /tmp/cri-dockerd.rpm ]] && dzWget /tmp/cri-dockerd.rpm https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd-0.3.1-3.el7.x86_64.rpm
rpm -ivh /tmp/cri-dockerd.rpm
systemctl enable --now cri-docker
sed -i 's#ExecStart=/usr/bin/cri-dockerd --container-runtime-endpoint fd://#ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.8 --container-runtime-endpoint fd://#' /usr/lib/systemd/system/cri-docker.service
systemctl daemon-reload

logStage $StageNo "Config Linux"
KubernetesConf=/etc/sysctl.d/kubernetes.conf
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/$KubernetesConf $KubernetesConf && logFile $KubernetesConf
sysctl -p
logStep "加载网桥过滤模块 lsmod | grep br_netfilter"
modprobe br_netfilter
let StageNo+=1

logStage $StageNo "Config ipvs"
IpvsModules=/etc/sysconfig/modules/ipvs.modules
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/$IpvsModules $IpvsModules && logFile $IpvsModules
logStep "lsmod | grep -e ip_vs -e nf_conntrack_ipv4"
chmod u+x $IpvsModules
source $IpvsModules
let StageNo+=1

logStage $StageNo "Config kubelet"
KubeletModules=/etc/sysconfig/kubelet
/bin/cp -fa $DZ_CLOUD_PATH/cloud-file/CentOS7/volume/$KubeletModules $KubeletModules && logFile $KubeletModules
systemctl enable --now kubelet
sed -i '/disabled_plugins/s/^\(.*\)$/# \1/g' /etc/containerd/config.toml && logFile /etc/containerd/config.toml
systemctl restart containerd
let StageNo+=1

logStage $StageNo "Config Service"
logStep "chronyd"
systemctl enable --now chronyd
logStep "firewalld"
systemctl stop firewalld
systemctl disable firewalld
logStep "iptables"
systemctl stop iptables
systemctl disable iptables
logStep "selinux"
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && logFile /etc/sysconfig/selinux
logStep "swap"
swapoff -a
sed -i '/ swap /s/^\(.*\)$/# \1/g' /etc/fstab && logFile /etc/fstab
logStep "k8s"
systemctl enable --now kubelet
let StageNo+=1
