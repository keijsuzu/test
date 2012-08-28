# .bash_profile

export GREP_COLORS=""

export HISTTIMEFORMAT='%Y-%m-%d %T ';

export PS1="[\[\033[01;33m\]\h\[\033[0m\]@\u \[\033[01;36m\]\w\[\033[0m\] ]$ "

export HISTFILE="/home/`whoami`/.bash_history"
shopt -s histappend 

export HISTSIZE=2000 

alias screen='screen -U'

alias ctags=~/vim/tools/ctags/bin/ctags

# ls color config
# alias l='ls -G'
export CLICOLOR=1
export LSCOLORS='ExfxcxdxBxegedabagacad'

# grep color config
alias grep="grep --color"

export PATH=${PATH}:/home/keijsuzu/bin

#export LANG=ja_JP.eucJP

if [ -f ~/.bashrc_local ]; then
    . ~/.bashrc_local
fi

if [ -f ~/.zshrc -a -x /usr/bin/zsh -a "$SHELL" = "`which bash`" ]; then
    exec /usr/bin/zsh -l
fi

#ssh-add -l > /dev/null 2>&1
#if [ $? -ne 0 ];then
#	eval `ssh-agent`
#	ssh-add
#fi
