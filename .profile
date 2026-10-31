export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
export ELECTRON_OZONE_PLATFORM_HINT=wayland

[ -r "$HOME/.secrets" ] && . "$HOME/.secrets"

# goose: run shell tool commands with zsh
export GOOSE_SHELL=/usr/sbin/zsh
