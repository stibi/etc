#export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'

# virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7
export WORKON_HOME=~/virtualenvs
source /usr/bin/virtualenvwrapper.sh
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
export M2_HOME=/opt/maven/
export M2=$M2_HOME/bin

source /etc/profile
source ~/.git_completion.sh

# Check for an interactive session
[ -z "$PS1" ] && return

# protoze blbnou xorg aplikace spoustene z konzole
xhost + >> /dev/null &&
fortune
echo

export EDITOR="vim"
export PAGER="most"
export PATH=$PATH:/home/stibi/bin:/opt/google_appengine/:/home/stibi/Programovani/atlassian-plugin-sdk-3.8/bin/

HISTFILE=~/.history
SAVEHIST=500

source /home/stibi/Programovani/Projekty/dancepill/e

alias ls='ls -F --color=auto'
alias lsbs='ls -lrhS'
alias ll='ls -lah'
alias la='ls -a'
alias dfh='df -h'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias g='egrep --color'
alias gi='egrep --color -i'
alias svim='sudo vim'
alias scat='sudo cat'
alias tailf='tail -f'
alias stailf='sudo tailf'
alias p='ping www.seznam.cz'
alias reload='source ~/.bashrc'
alias beat='mplayer -playlist /home/stibi/beat128.mp3.m3u'

# JIRA
#alias tailjira='tail -f /opt/jira/atlassian-jira-enterprise-4.2.2-b589-standalone/logs/catalina.out'

function git_prompt {
  local STATUS=`git status 2>&1`
  if [[ "$STATUS" == *'Not a git repository'* ]]
  then
    echo ""
  else
    if [[ "$STATUS" == *'working directory clean'* ]]
    then
      echo -e '\033[0;32m±\033[m '
    else
      echo -e '\033[0;31m±\033[m '
    fi
  fi
}

if [[ ${EUID} == 0 ]] ; then
  PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
else
  PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] $(__git_ps1 "(%s)")$(git_prompt)'
fi

#PS1='[\u@\h \W]\$ '
#PS1='[$(date +%H:%M)]•\e[0;32m\u\e[0m \w \$> '
#export PS1=' \e[0;32m\h\e[1;37m@\e[0;32m\u\e[0m•\W\$> '
#export PS1='\[\033[01;32m\]\u@\h \[\033[01;34m\]\W \$ \[\033[00m\]'
#PS1="\n\[\e[32;1m\](\[\e[37;1m\]\u\[\e[32;1m\])-(\[\e[37;1m\]jobs:\j\[\e[32;1m\])-(\[\e[37;1m\]\w\[\e[32;1m\])\n(\[\[\e[37;1m\]!\!\[\e[32;1m\])-> \[\e[0m\]"
#PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;32m\] '

#export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=lcd"
export JAVA_FONTS=/usr/share/fonts/TTF

complete -cf sudo
