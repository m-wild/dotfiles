## .bashrc
## michael@mwild.me

export EMAIL='michael@mwild.me'

if [[ -d /usr/local/sbin ]]; then
  export PATH=$PATH:/usr/local/sbin
fi

# import extra bash completion
if [[ -f /usr/local/etc/bash_completion ]]; then
  source /usr/local/etc/bash_completion
fi

# macos only stuff
if [[ $(uname -s) == 'Darwin' ]]; then

  # re-add any ssh keys from the keychain (-A)
  ssh-add -A > /dev/null 2>&1

  # use brew coreutils
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

fi

# set somewhere to store logs
export APP_LOGS=~/.logs
if [[ ! -d $APP_LOGS ]]; then mkdir $APP_LOGS; fi

# vim not emacs pls
export EDITOR=vim

# nodejs
export NVM_DIR="$HOME/.nvm"
if [[ -f /usr/local/opt/nvm/nvm.sh ]]; then
  source /usr/local/opt/nvm/nvm.sh
fi

# ruby
eval "$(rbenv init -)"

# golang
export GOPATH=~/go
if [[ -d $GOPATH/bin ]]; then
  export PATH=$PATH:$GOPATH/bin
fi


# aliases
alias ls='ls -p --color=auto'
alias ll='ls -alF'
alias grep='grep --color=auto'

# prompt/history
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTTIMEFORMAT="%Y-%m-%d.%H:%M:%S  "
shopt -s histappend

# backup history on startup
export HISTFILEBACKUP="$APP_LOGS/shell-history-$(date +%Y-%m).log"
if [[ ! -e $HISTFILEBACKUP ]]; then
  cp $HISTFILE $HISTFILEBACKUP
  tail -n 200 $HISTFILEBACKUP > $HISTFILE
  history -c # clear memory
  history -r # re-read file
fi

# define *~*~ colors
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 4)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
normal=$(tput sgr0)


_prompt() {
  history -a # append
  # todo: build your own history logging like in powershell...
  # useful:
  # - $OLDPWD
}

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=true
export GIT_PS1_SHOWCOLORHINTS=true


export PS1="[\W]\\$ "

if [[ -n $(type -t __git_ps1) ]]; then
  export PS1="[\W\$(__git_ps1 '\[${black}\] %s\[${blue}\]')]\\$ "
fi
if [[ -n $SSH_TTY ]]; then
  export PS1="[\[${blue}\]\h\[${normal}\]:\W]\\$ "
fi

