#!/bin/bash -i

PluginDirPath=$DZ_CTL_PATH/src/plugins
PluginCode=$1
Argument=$*
[[ ! -f $PluginDirPath/$PluginCode/index.sh ]] && echo Error PluginCode && exit
source $PluginDirPath/$PluginCode/index.sh $Argument
