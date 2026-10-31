dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY XDG_RUNTIME_DIR
exec pipewire &
exec pipewire-pulse &
exec wireplumber &
exec noctalia
#exec swww-daemon &
#cd $HOME/.config/swww/ && exec ./update-background &
#exec eww daemon &
#exec eww open bar --no-daemonize &
#exec keepassxc --minimized &