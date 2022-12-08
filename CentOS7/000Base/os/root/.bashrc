# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

chmod 755 -R /root/.dz
alias dzcheck="/root/.dz/dzcheck.sh"
alias dzset="/root/.dz/dzset.sh"
alias dzsys="/root/.dz/dzsys.sh"
alias dzinit="/root/.dz/dzinit.sh"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
