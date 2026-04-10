#!/bin/bash
exec >/tmp/niri-autostart.log 2>&1
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

sleep 0.2
/usr/bin/alacritty --title "niri-main" &
sleep 0.2
/usr/bin/alacritty --title "niri-clock" -e tty-clock -c -b -s -C 6 &
sleep 0.2
/usr/bin/alacritty --title "niri-htop" -e htop &
sleep 0.2
/usr/bin/alacritty --title "niri-nvtop" -e nvtop &
sleep 0.2
niri msg action focus-column-first
sleep 0.2
niri msg action consume-window-into-column
sleep 0.2
niri msg action focus-column-right
sleep 0.2
niri msg action consume-window-into-column
