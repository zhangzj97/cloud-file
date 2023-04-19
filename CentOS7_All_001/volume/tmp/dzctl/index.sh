#!/bin/bash -i

PluginPath=/tmp/dzctl/src/plugins

PluginCode=$1
PluginActionCode=$2

case $PluginCode in
host)
  source $PluginPath/dz-host/index.sh $PluginActionCode
  ;;
docker)
  source $PluginPath/dz-docker/index.sh $PluginActionCode
  ;;
jenkins)
  source $PluginPath/dz-jenkins/index.sh $PluginActionCode
  ;;
harbor)
  source $PluginPath/dz-harbor/index.sh $PluginActionCode
  ;;
nginx)
  source $PluginPath/dz-nginx/index.sh $PluginActionCode
  ;;
nacos)
  source $PluginPath/dz-nacos/index.sh $PluginActionCode
  ;;
nexus)
  source $PluginPath/dz-nexus/index.sh $PluginActionCode
  ;;
k8s)
  source $PluginPath/dz-k8s/index.sh $PluginActionCode
  ;;
k3s)
  source $PluginPath/dz-k3s/index.sh $PluginActionCode
  ;;
rancher)
  source $PluginPath/dz-rancher/index.sh $PluginActionCode
  ;;
mysql80)
  source $PluginPath/dz-mysql80/index.sh $PluginActionCode
  ;;
mysql56)
  source $PluginPath/dz-mysql56/index.sh $PluginActionCode
  ;;
mysql57)
  source $PluginPath/dz-mysql57/index.sh $PluginActionCode
  ;;
zookeeper)
  source $PluginPath/dz-zookeeper/index.sh $PluginActionCode
  ;;
nodejs)
  source $PluginPath/dz-nodejs/index.sh $PluginActionCode
  ;;
redis)
  source $PluginPath/dz-redis/index.sh $PluginActionCode
  ;;
mongdb)
  source $PluginPath/dz-mongdb/index.sh $PluginActionCode
  ;;
tomcat)
  source $PluginPath/dz-tomcat/index.sh $PluginActionCode
  ;;
springboot)
  source $PluginPath/dz-springboot/index.sh $PluginActionCode
  ;;
*)
  echo 'You do not select a number between 1 to 4'
  ;;
esac
