#!/bin/bash -i

PluginPath=./src/plugins

PluginCode=$1
PluginActionCode=$2

case $PluginCode in
host)
    source /tmp/dzctl/src/plugins/dz-host/index.sh
    ;;
jenkins)
    echo 'You select 2'
    ;;
3)
    echo 'You select 3'
    ;;
4)
    echo 'You select 4'
    ;;
*)
    echo 'You do not select a number between 1 to 4'
    ;;
esac
