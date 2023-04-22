#!/bin/bash -i

# Validate
[[ $* =~ host ]] && echo Error dcoker : need action && exit

# Dispatch
MethodPath=/tmp/cloud-file/CentOS7/volume/tmp/dzctl/src/plugins/dz-demo/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
