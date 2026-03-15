exec swww-daemon &
cd $HOME/.config/swww/ && exec ./update-background &
exec eww daemon &
exec eww open bar --no-daemonize &