# .bashrc


# If not running interactively, don't do anything
[[ $- != *i* ]] && return


source ~/.rc

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

