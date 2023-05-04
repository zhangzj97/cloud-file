# 001All

## Step

### Release

```bash

# Download Install file
# https://raw.githubusercontent.com/zhangzj97/cloud-file/main/install.sh
curl -fsSL https://raw.fastgit.org/zhangzj97/cloud-file/main/install.sh > /tmp/dzinit.sh | chmod u+x /tmp/dzinit.sh | ln -fs /tmp/dzinit.sh /bin/dzinit

dzinit /z1

dzctl server docker
dzctl server ssl --domain=192.168.226.100 --port=9005
dzctl server ssl --domain=192.168.226.100 --port=9012

dzctl server harbor --domain=192.168.226.100 --port=9005

dzctl server rancher --domain=192.168.226.100 --port=9012



```

### Snipaste

### Test

```bash

# kubectl create deployment nginx --image=nginx:1.14-alpine
kubectl create deployment nginxtest --image=nginx
kubectl expose deployment nginxtest --port=80 --type=NodePort
kubectl get pods,service

```

### Harbor

```bash
docker tag dz-docker-dashboard-portainer-ce:1.0.0 192.168.226.100:9005/public/dz-docker-dashboard-portainer-ce:1.0.0
docker tag dz-docker-dashboard-portainer-ce:1.0.0 192.168.226.100:9005/t/dz-docker-dashboard-portainer-ce:1.0.0
docker push 192.168.226.100:9005/dz-docker-dashboard-portainer-ce:1.0.0
docker login -u User1 192.168.226.100:9005
```

### K3S

```bash
curl -sfL http://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_EXEC=server sh -

k3s kubectl get node

```
