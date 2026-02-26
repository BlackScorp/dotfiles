# .bashrc


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


play() {
    mpv --playlist="$HOME/Musik/$1.txt"
}

alias music-on='mpv --playlist=~/Musik/coding.txt'
alias docker-up='sudo ln -s /etc/sv/docker /var/service/ && sudo sv start docker'
alias docker-down='sudo sv stop docker && sudo rm /var/service/docker'
alias open='xdg-open'
alias ll='ls -la'
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
