#!/bin/bash -i

# Validate
[[ $* =~ ssl ]] && echo Error dcoker : need action && exit

# Dispatch
MethodPath=/ /volume/tmp/dzctl/src/plugins/dz-ssl/methods
MethodCode=$1
[[ ! -f $MethodPath/$MethodCode/index.sh ]] && echo Error code && exit
source $MethodPath/$MethodCode/index.sh $MethodArgument
