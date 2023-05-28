# dotfiles-hypr

### Previews

## Install

### paru
Run as user NOT ROOT!
```bash
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### Packages
Base
```
paru -S hyprland polkit-gnome bluez bluez-utils \
ffmpeg pavucontrol thunar sddm-git inotify-tools \
wl-clipboard cliphist grimblast-git playerctl \
thunar-archive-plugin alacritty swaylock-effects \
nwg-look-bin pamixer fish starship
```

#### Themeing
```
paru -S papirus-folders-catppuccin-git catppuccin-gtk-theme-mocha catppuccin-cursors-mocha
```

With eww
```
paru -S upower eww-wayland jaq socat gjs coreutils gtk2 inotify-tools
```

Addons (stuff i like)
```
paru -S ufw obsidian micro bellsym-git
```

With waybar (see the waybar branch)
```
paru -S waybar-hyprland-git wlogout rofi-lbonn-wayland-git hyprpaper swaync
```

If you opted to install bellsym-git. You can use the do:
```bash
$ cd dotfiles-hypr
$ bellsym bellsym.json
```

### Configs

[Hyprland](.config/hypr/hyprland.conf) (change these to your liking)
```
$term=alacritty
$browser=chromium
$file=thunar
$editor=code
$notes=obsidian
$layout=dwindle # dwindle or master
$mod=SUPER # Mod key

# Wallpaper
exec-once = swaybg -m fill -i ~/.local/share/backgrounds/wall.jpg
exec-once = hyprpaper

# Bar
exec-once = waybar
exec-once = bash ~/.config/eww/bel/scripts/init
```

[hyprpaper](.config/hypr/hyprpaper.conf)
You can use this to change the wallpaper. It is dynamicly set unlike swaybg. 

[eww](.config/eww/)
There is a few options for the bar here I use bel since it is complete.


<details>
<summary> Shortcuts </summary>

| Shortcut   | What it does   |
|---|---|
| `SUPER+RETURN` | open terminal |
| `SUPER+B` | open browser |
| `SUPER+C` | open editor |
| `SUPER+O` | open notes |
| `SUPER+E` | open thunar |
| `SUPER+Q` | quit |
| `SUPER+D` | rofi |
| `SUPER+F` | fullscreen |
| `SUPER+[number]` | open workspace [number] |
| `SUPER+SHIFT+[number]` | move to workspace [number] |
</details>
