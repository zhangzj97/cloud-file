#!/bin/bash

# 添加 DNS
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

# 配置ipvs功能
## TODO 在kubernetes中service有两种代理模型，一种是基于iptables的，一种是基于ipvs的
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
