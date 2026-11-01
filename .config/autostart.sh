dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY XDG_RUNTIME_DIR

# .NET (Godot Mono, dotnet CLI): make PATH/DOTNET_ROOT visible to GUI apps
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
dbus-update-activation-environment DOTNET_ROOT PATH
exec pipewire &
exec pipewire-pulse &
exec wireplumber &
exec noctalia
#exec swww-daemon &
#cd $HOME/.config/swww/ && exec ./update-background &
#exec eww daemon &
#exec eww open bar --no-daemonize &
#exec keepassxc --minimized &