# K8s

## Step

```bash


# vpn
echo "192.168.226.102 testk8s" >>/etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" >>/etc/hosts
echo "140.82.113.3    raw.github.com" >>/etc/hosts

# init
curl -fsSL  https://raw.githubusercontent.com/zhangzj97/cloud-file/main/CentOS7/000Base/os/root/dzinit.sh | bash
# dzset 102 testk8s

# alias
. /root/.bashrc

# Install
yum install ntpdate -y

yum install -y nc
yum install -y yum-utils
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
yum install -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp
yum install -y kubelet-1.25.5 kubeadm-1.25.5 kubectl-1.25.5 --disableexcludes=kubernetes
# yum remove kubelet kubeadm kubectl
# yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

ntpdate time.windows.com  
# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable Firewalld
systemctl stop firewalld
systemctl disable firewalld

# Disable Swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

systemctl daemon-reload

mkdir -p /root/.dzrepo
curl -o /root/.dzrepo/cri-dockerd-0.2.6.amd64.tgz -fsSL https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.6/cri-dockerd-0.2.6.amd64.tgz
tar -xvf /root/.dzrepo/cri-dockerd-0.2.6.amd64.tgz -C /root/.dzrepo/
cp /root/.dzrepo/cri-dockerd/cri-dockerd /usr/bin/ 

# containerd config default > /etc/containerd/config.toml

# Start service
systemctl daemon-reload
systemctl enable --now containerd
systemctl enable --now docker
systemctl enable --now cri-docker
systemctl enable --now kubelet

systemctl status containerd
systemctl status docker
systemctl status cri-docker
systemctl status kubelet

systemctl daemon-reload
systemctl restart containerd
systemctl restart docker
systemctl restart cri-docker
systemctl restart kubelet


# !!!! Control Plane 

# mkdir -p /root/.dzrepo/
# curl -o /root/.dzrepo/go1.18.3.linux-amd64.tar.gz.tgz -fsSL https://golang.google.cn/dl/go1.18.3.linux-amd64.tar.gz
# tar -xvf /root/.dzrepo/go1.18.3.linux-amd64.tar.gz.tgz -C /root/.dzrepo/
# cp -r /root/.dzrepo/go/ /usr/local/

# 添加环境变量，编辑/etc/profile 文件，在文件末尾添加以下配置
# export GOROOT=/usr/local/go
# export GOPATH=/home/gopath
# export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 加载/etc/profile文件
# source /root/.bash_profile

# 配置go proxy代理
# go env -w GOPROXY="https://goproxy.io,direct"


# 验证golang是否安装完成，执行 go version命令



docker pull rancher/rancher

# Init

kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock  

kubeadm init \
--apiserver-advertise-address=192.168.226.102 \
--cri-socket unix:///var/run/cri-dockerd.sock \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16  \
--image-repository registry.aliyuncs.com/google_containers \
--v=6


kubeadm init \
--apiserver-advertise-address=192.168.226.102 \
--kubernetes-version=v1.25.5 \
--cri-socket unix:///var/run/containerd/containerd.sock \
--image-repository registry.aliyuncs.com/google_containers \
--control-plane-endpoint=192.168.226.102:6443 \



kubeadm reset --cri-socket unix:///var/run/containerd/containerd.sock
kubeadm reset --cri-socket unix:///var/run/cri-dockerd.sock


 kubeadm config images list --kubernetes-version=v1.25.5 --image-repository registry.aliyuncs.com/google_containers
 kubeadm config images pull --cri-socket unix:///var/run/cri-dockerd.sock --kubernetes-version=v1.25.5 --image-repository registry.aliyuncs.com/google_containers



# 创建默认配置文件
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
 
# 修改Containerd的配置文件
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
sed -i "s#registry.k8s.io#registry.cn-hangzhou.aliyuncs.com/chenby#g" /etc/containerd/config.toml
sed -i "s#config_path\ \=\ \"\"#config_path\ \=\ \"/etc/containerd/certs.d\"#g" /etc/containerd/config.toml
 
mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://hub-mirror.c.163.com"]
  capabilities = ["pull", "resolve"]
EOF

mkdir /root/.dzrepo/
curl -o /root/.dzrepo/go1.18.3.linux-amd64.tar.gz.tgz -fsSL https://golang.google.cn/dl/go1.18.3.linux-amd64.tar.gz
tar -xvf /root/.dzrepo/go1.18.3.linux-amd64.tar.gz.tgz -C /root/.dzrepo/
cp -r /root/.dzrepo/go/ /usr/local/

cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket

```



root      36067  35857 15 08:01 ?        00:01:01 

kube-apiserver \
--advertise-address=192.168.226.102 \
--allow-privileged=true \
--authorization-mode=Node,RBAC \
--client-ca-file=/etc/kubernetes/pki/ca.crt \
--enable-admission-plugins=NodeRestriction \
--enable-bootstrap-token-auth=true \
--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt \
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt \
--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key \
--etcd-servers=https://127.0.0.1:2379 \
--kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \
--kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \
--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \
--proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt \
--proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key \
--requestheader-allowed-names=front-proxy-client \
--requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt \
--requestheader-extra-headers-prefix=X-Remote-Extra- \
--requestheader-group-headers=X-Remote-Group \
--requestheader-username-headers=X-Remote-User \
--secure-port=6443 \
--service-account-issuer=https://kubernetes.default.svc.cluster.local \
--service-account-key-file=/etc/kubernetes/pki/sa.pub \
--service-account-signing-key-file=/etc/kubernetes/pki/sa.key \
--service-cluster-ip-range=10.96.0.0/12 \
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt \
--tls-private-key-file=/etc/kubernetes/pki/apiserver.key\

/usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf \
--kubeconfig=/etc/kubernetes/kubelet.conf \
--config=/var/lib/kubelet/config.yaml \
--container-runtime-endpoint=unix:///var/run/cri-dockerd.sock \
--pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9



docker run --privileged -d --name rancher --restart=unless-stopped -p 80:80 -p 443:443 -v /opt/rancher:/var/lib/rancher rancher/rancher
 docker ps | grep rancher

mkdir -p /root/.dzmount/rancher/var/lib/
mkdir -p /root/.dzmount/rancher/var/log/

docker run -d --restart=always --privileged=true -v /root/.dzmount/rancher/var/lib/rancher:/var/lib/rancher -v /root/.dzmount/rancher/var/log/auditlog:/var/log/auditlog -p 8871:80 -p 8870:443 --name rancher rancher/rancher 

sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  rancher/rancher-agent:v2.6.3 --server https://192.168.226.102:8870 --token drggqntp6cggxrw6nql4rv9zt5z7rvnnmsq67dzz8mt5gr8mcxxhjl --ca-checksum fdbf2a24beec1743bfa6b6a0e7dd68231d82587574b97dc686d6aa93e8fe2aa1 --etcd --controlplane --worker