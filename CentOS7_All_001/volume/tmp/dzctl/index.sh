#!/bin/bash -i

PluginPath=./src/plugins

ComponentCode=$1
ComponentActionCode=$2
echo $1 $2 $PluginPath
echo $1 $2 $PluginPath
echo $1 $2 $PluginPath
echo $1 $2 $PluginPath
echo $1 $2 $PluginPath
echo $1 $2 $PluginPath
if [[ $ComponentCode =~ 'host' ]]; then
    source $PluginPath/dz-host/index.sh
fi
