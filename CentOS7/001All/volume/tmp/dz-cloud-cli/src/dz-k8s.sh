#!/bin/bash

# 添加 DNS
echo ========== 添加 DNS ==========
## 清除 K8S DNS
sed -i '/# <Dz> K8S/,/# <\/Dz> K8S/d' /etc/hosts
## 添加 K8S DNS
echo '# <Dz> K8S' >>/etc/hosts
echo '192.168.226.201 master1' >>/etc/hosts
echo '192.168.226.202 master2' >>/etc/hosts
echo '192.168.226.211 node1' >>/etc/hosts
echo '192.168.226.212 node2' >>/etc/hosts
echo '# </Dz> K8S' >>/etc/hosts

# 修改 linux 内核参数
echo ========== 修改 linux 内核参数 ==========
## 添加网桥过滤和地址转发功能
if [ ! -f /etc/sysctl.d/kubernetes.conf ]; then
  touch /etc/sysctl.d/kubernetes.conf
fi
sed -i '/# <Dz> K8S/,/# <\/Dz> K8S/d' /etc/sysctl.d/kubernetes.conf
echo '# <Dz> K8S' >>/etc/sysctl.d/kubernetes.conf
echo 'net.bridge.bridge-nf-call-ip6tables=1' >>/etc/sysctl.d/kubernetes.conf
echo 'net.bridge.bridge-nf-call-iptables=1' >>/etc/sysctl.d/kubernetes.conf
echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.d/kubernetes.conf
echo '# </Dz> K8S' >>/etc/sysctl.d/kubernetes.conf
## 重新加载配置
sysctl -p
## 加载网桥过滤模块
modprobe br_netfilter
## 查看网桥过滤模块是否加载成功
lsmod | grep br_netfilter

# 处理服务
echo ========== 处理服务 ==========
## 开启 chronyd
systemctl start chronyd
systemctl enable chronyd
## 关闭 firewalld
systemctl stop firewalld
systemctl disable firewalld
## 关闭 iptables
systemctl stop iptables
systemctl disable iptables
## 关闭 selinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
# 关闭 swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 配置 ipvs 功能
echo ========== 配置 ipvs 功能 ==========
## 安装 ipset
IpsetVersion=$(rpm -qa ipset)
if [[ ! $IpsetVersion =~ 'ipset' ]]; then
  yum install -y ipset
fi
## TODO 安装 ipvsadmin
IpvsadminVersion=$(rpm -qa ipvsadmin)
if [[ ! $IpvsadminVersion =~ 'ipvsadmin' ]]; then
  yum install -y ipvsadmin
fi
## 新建一个脚本
rm -f /etc/sysconfig/modules/ipvs.modules
touch /etc/sysconfig/modules/ipvs.modules
echo '#!/bin/bash' >>/etc/sysconfig/modules/ipvs.modules
echo 'modprobe -- ip_vs' >>/etc/sysconfig/modules/ipvs.modules
echo 'modprobe -- ip_vs_rr' >>/etc/sysconfig/modules/ipvs.modules
echo 'modprobe -- ip_vs_wrr' >>/etc/sysconfig/modules/ipvs.modules
echo 'modprobe -- ip_vs_sh' >>/etc/sysconfig/modules/ipvs.modules
echo 'modprobe -- nf_conntrack_ipv4' >>/etc/sysconfig/modules/ipvs.modules
chmod +x /etc/sysconfig/modules/ipvs.modules
source /etc/sysconfig/modules/ipvs.modules
lsmod | grep -e ip_vs -e nf_conntrack_ipv4

# 安转 K8S
echo ========== 安转 K8S ==========
## 复制 repo 文件
mv /tmp/cloud-file/CentOS7/001All/volume/etc/yum.repos.d/dz-kubernetes.repo /etc/yum.repos.d/dz-kubernetes.repo
## 安装 组件
yum remove -y kubelet kubeadm kubectl
yum install -y --setopt=obsoletes=0 kubelet-1.17.4-0 kubectl-1.17.4-0 kubeadm-1.17.4-0
## 配置
if [ ! -f /etc/sysconfig/kubelet ]; then
  touch /etc/sysconfig/kubelet
fi
sed -i '/# <Dz> K8S/,/# <\/Dz> K8S/d' /etc/sysconfig/kubelet
echo '# <Dz> K8S ' >>/etc/sysconfig/kubelet
echo 'KUBELET_CGROUP_ARGS=--cgroup-driver=systemd' >>/etc/sysconfig/kubelet
echo 'KUBE_PROXY_MODE=ipvs' >>/etc/sysconfig/kubelet
echo '# </Dz> K8S' >>/etc/sysconfig/kubelet
## 开启 kubelet
systemctl start kubelet
systemctl enable kubelet
## 准备集群镜像
kubeadm config images list
images=(
  kube-apiserver:v1.17.4
  kube-controller-manager:v1.17.4
  kube-scheduler:v1.17.4
  kube-proxy:v1.17.4
  pause:3.1
  etcd:3.4.3-0
  coredns:1.6.5
)
for imageName in ${images[@]}; do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
docker images
## 初始化集群
## TODO 学习 参数意义
# kubeadm init --kubernetes-version=v1.17.4 --apiserver-advertise-address=192.168.226.201 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12
kubeadm init \
  --kubernetes-version=v1.17.4 \
  --apiserver-advertise-address=192.168.226.201 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
## kuebadm toke
## kubeadm init 会生成 token 以供 worker 去 kubeadm join
kubeadm token list
kubeadm token create --print-join-command
## 永久token
# kubeadm token create --ttl 0 --print-join-command

# 安装 docker
echo ========== 安转 docker ==========
## 复制 repo 文件
mv /tmp/cloud-file/CentOS7/001All/volume/etc/yum.repos.d/dz-docker.repo /etc/yum.repos.d/dz-docker.repo
## 安装 docker-ce
yum install -y --setopt=obsoletes=0 docker-ce-18.06.3.ce-3.el7
## 配置
## Docker在默认情况下使用的Cgroup Driver为cgroupfs，而kubernetes推荐使用systemd来代替cgroupfs
rm -f /etc/docker/daemon.json
mkdir /etc/docker
touch /etc/docker/daemon.json
echo '{' >>/etc/docker/daemon.json
echo '"exec-opts": ["native.cgroupdriver=systemd"],' >>/etc/docker/daemon.json
echo '"registry-mirrors": ["https://kn0t2bca.mirror.aliyuncs.com"]' >>/etc/docker/daemon.json
echo '}' >>/etc/docker/daemon.json
## 开启 docker
systemctl restart docker
systemctl enable docker
