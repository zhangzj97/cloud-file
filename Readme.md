# 001All

## Step

### Release

```
192.168.226.100 base
192.168.226.101 template
192.168.226.102 test01
192.168.226.103 103xxx
192.168.226.104 104xxx
192.168.226.105 105xxx
192.168.226.106 106xxx
192.168.226.107 107xxx
192.168.226.108 108xxx
192.168.226.109 109xxx
192.168.226.110 110xxx
192.168.226.111 master01
192.168.226.112 master02
192.168.226.113 113xxx
192.168.226.114 114xxx
192.168.226.115 115xxx
192.168.226.116 worker01
192.168.226.117 worker02
192.168.226.118 118xxx
192.168.226.119 119xxx
192.168.226.120 120xxx

192.168.226.102 gitlab.dylan.zhang
192.168.226.102 harbor.dylan.zhang
192.168.226.102 docker.dylan.zhang
192.168.226.102 rancher.dylan.zhang
192.168.226.102 harbor.zhangzejie.top

dzctl server set --ip=192.168.226.100 --name=base
dzctl server set --ip=192.168.226.101 --name=template
dzctl server set --ip=192.168.226.102 --name=test01
dzctl server set --ip=192.168.226.103 --name=103xxx
dzctl server set --ip=192.168.226.104 --name=104xxx
dzctl server set --ip=192.168.226.105 --name=105xxx
dzctl server set --ip=192.168.226.106 --name=106xxx
dzctl server set --ip=192.168.226.107 --name=107xxx
dzctl server set --ip=192.168.226.108 --name=108xxx
dzctl server set --ip=192.168.226.109 --name=109xxx
dzctl server set --ip=192.168.226.110 --name=110xxx
dzctl server set --ip=192.168.226.111 --name=master01
dzctl server set --ip=192.168.226.112 --name=master02
dzctl server set --ip=192.168.226.113 --name=113xxx
dzctl server set --ip=192.168.226.114 --name=114xxx
dzctl server set --ip=192.168.226.115 --name=115xxx
dzctl server set --ip=192.168.226.116 --name=worker01
dzctl server set --ip=192.168.226.117 --name=worker02
dzctl server set --ip=192.168.226.118 --name=118xxx
dzctl server set --ip=192.168.226.119 --name=119xxx
dzctl server set --ip=192.168.226.120 --name=120xxx

```

```bash

# Download Install file
# https://raw.githubusercontent.com/zhangzj97/cloud-file/main/install.sh
curl -fsSL https://raw.fastgit.org/zhangzj97/cloud-file/main/install.sh > /tmp/dzinit.sh | chmod u+x /tmp/dzinit.sh | ln -fs /tmp/dzinit.sh /bin/dzinit

# docker rm -f $(docker ps -a -q)
# docker image prune -a

dzinit /z && dzinit /z

dzctl server docker

dzctl server ssl --port=9002 && dzctl server docker-web --port=9002
dzctl server ssl --port=9012 && dzctl server harbor --port=9012
dzctl server ssl --port=9022 && dzctl server rancher --port=9022
dzctl server ssl --port=9032 && dzctl server jenkins --port=9032
dzctl server ssl --port=9042 && dzctl server gitlab --port=9042

systemctl daemon-reload && systemctl restart docker && dzctl server harbor --port=9012

https://192.168.226.102:9002 http://192.168.226.102:9001 # portainer
https://192.168.226.102:9012 http://192.168.226.102:9011 # harbor    admin:123123
https://192.168.226.102:9022 http://192.168.226.102:9021 # rancher   admin:123123
https://192.168.226.102:9032 http://192.168.226.102:9031 # jenkins   admin:123123
https://192.168.226.102:9042 http://192.168.226.102:9041 # gitlab    admin:123123

```

### User

#### Portainer

|           |        |              |              |
| --------- | ------ | ------------ | ------------ |
| Portainer |        | admzzj       | 5171176db7f2 |
| Portainer | dzteam | dzteamuser01 | b622730c7bdc |
| Harbor    |        | admin        | A613dc8f55e8 |
| Harbor    |        | admzzj       | A613dc8f55e8 |
| Jenkins   |        | admin        | 572a2042dfa0 |
| Jenkins   |        | admzzj       | 572a2042dfa0 |

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

### helm

```bash
curl -fsSL https://raw.fastgit.org/helm/helm/main/scripts/get-helm-3> /tmp/helm.sh | bash
```

https://get.helm.sh/helm-v3.11.3-linux-amd64.tar.gz
https://github.com/helm/helm/archive/refs/tags/v3.11.3.tar.gz

wget -q -t0 -T5 -O /tmp/helm.tar.gz https://get.helm.sh/helm-v3.11.3-linux-amd64.tar.gz --no-check-certificate
tar -xzf /tmp/helm.tar.gz -C /tmp/

https://get.helm.sh/helm--linux-amd64.tar.gz

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

### 备份 harbor

### Gitlab

Current version: gitlab-ee=15.11.3-ee.0

Configure GitLab for your system by editing /etc/gitlab/gitlab.rb file
And restart this container to reload settings.
To do it use docker exec:

docker exec -it gitlab editor /etc/gitlab/gitlab.rb
docker restart gitlab

For a comprehensive list of configuration options please see the Omnibus GitLab readme
https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md

If this container fails to start due to permission problems try to fix it by executing:

docker exec -it gitlab update-permissions
docker restart gitlab

Cleaning stale PIDs & sockets

docker exec -it dz-gitlab gitlab-backup create
docker exec -it dz-gitlab gitlab-backup restore xxxx
oldPassword: SNvPM+FwRbTUxSMQ0TZpmx4RRf84wXhFwu0M4+oO/Ss=
