# .zshrc

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git history fzf)
source "$ZSH/oh-my-zsh.sh"

# Shared aliases and functions (used by bash and zsh)
source ~/.rc

export QT_QPA_PLATFORMTHEME=qt5ct
export PATH="$PATH:$HOME/.lmstudio/bin:$HOME/.dotnet"

# API keys and other secrets live outside the repo (~/.secrets, chmod 600)
[ -r "$HOME/.secrets" ] && . "$HOME/.secrets"
