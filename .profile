export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.dotnet:$PATH"

# .NET (Godot Mono, dotnet CLI) – shared by bash, zsh and GUI launches
export DOTNET_ROOT="$HOME/.dotnet"

export ELECTRON_OZONE_PLATFORM_HINT=wayland

[ -r "$HOME/.secrets" ] && . "$HOME/.secrets"

# goose: run shell tool commands with zsh
export GOOSE_SHELL=/usr/sbin/zsh
