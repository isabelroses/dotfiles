# dotfiles-hypr

## Install

### Yay
Run as user NOT ROOT!
```
git clone https://aur.archlinux.org/yay-bin
cd yay-bin
makepkg -si
```

### Packages
Base
```
yay -S hyprland-bin polkit-gnome bluez bluez-utils \
ffmpeg viewnior dunst pavucontrol thunar \
wl-clipboard wf-recorder swaybg grimblast-git \ ffmpegthumbnailer playerctl noise-suppression-for-voice \
thunar-archive-plugin alacritty swaylock-effects \
sddm-git nwg-look-bin papirus-icon-theme pamixer \
rofi-lbonn-wayland-git
```

Addons
```
yay -S ufw obsidian openvpn micro starship
```

With waybar
```
yay -S  waybar-hyprland-git wlogout 
```

With eww
```
yay -S upower eww-wayland jaq socat gjs coreutils
```

