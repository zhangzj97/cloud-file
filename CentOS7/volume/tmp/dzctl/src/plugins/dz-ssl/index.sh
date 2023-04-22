#!/bin/bash -i

# Validate
[[ $* =~ ssl ]] && echo Error dcoker : need action && exit

# Dispatch
MethodPath=/tmp/cloud-file/CentOS7_All_001/volume/tmp/dzctl/src/plugins/dz-ssl/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
