# ~/.profile: Executed by Bourne-compatible login SHells.
#

# Path to personal scripts and executables (~/Bin).
#
if [ -d "$HOME/Bin" ] ; then
	PATH=$HOME/Bin:$PATH
	export export 
fi

# Java home directory path.
#
#JAVA_HOME=$HOME/Bin/jre1.6.0_03
#JAVA_BINDIR=$JAVA_HOME/bin
#if [ -d "$HOME/Bin" ] ; then
#	export PATH=$JAVA_BINDIR:$PATH
#fi

# Environnement variables and prompt for Ash SHell
# or Bash.
#

# Classic prompt.
PS1='\u@\h:\w\$ '

# Light green and blue colored prompt.
#PS1='\e[1;32m\u@\h\e[0m:\e[1;34m\w\e[0m\$ '

# Light blue or yellow.
#PS1='\e[1;34m\u@\h:\w\e[0m\$ '
#PS1='\[\033[1;33m\]\u@\h:\w\[\033[0m\]\$ '

EDITOR='nano'
PAGER='less -EM'

export PS1 EDITOR PAGER

umask 022