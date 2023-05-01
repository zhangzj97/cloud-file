#!/bin/bash -i

PluginCode=ssl

MethodDirPath=$DZ_CTL_PATH/src/plugins/dz-$PluginCode/methods
MethodCode=$1
Argument=${*/$1/}
source $MethodDirPath/$MethodCode/index.sh ArgHolder $Argument
