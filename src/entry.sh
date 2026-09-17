#!/bin/bash
sudo chmod -R 777 /home/beta_vlsi/work 2>/dev/null || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1
# Launch TigerVNC with auth disabled
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -FrameRate 60
sleep 2
DISPLAY=:1 xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/wallpaper.jpeg --create -t string 2>/dev/null || DISPLAY=:1 xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /usr/share/backgrounds/wallpaper.jpeg --create -t string 2>/dev/null || true
/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &
DISPLAY=:1 xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus" --create -t string 2>/dev/null || true
tail -f /dev/null