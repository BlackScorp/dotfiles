exec pipewire &
exec pipewire-pulse &
exec wireplumber &
exec swww-daemon &
cd $HOME/.config/swww/ && exec ./update-background &
exec eww daemon &
exec eww open bar --no-daemonize &
exec keepassxc --minimized &
#exec /usr/libexec/polkit-gnome-authentication-agent-1 &