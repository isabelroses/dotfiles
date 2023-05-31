# Littral Trash

Still just learning nix. However if you are desprate enough to install this:

<<<<<<< HEAD
=======
## Install

### paru
Run as user NOT ROOT!
>>>>>>> refs/remotes/origin/nixos
```bash
git clone -b nixos https://github.com/isabelroses/dotfiles .setup
cd .setup
sudo nixos-rebuild switch --flake .#hydra
```
NOTE: THIS WILL NOT RUN UNLESS YOU EITHER REMOVE THE CLOUDFLARED MODLUES OR CREATE AND `env.nix` FILE AND HAVE A CLOUDFLARED TOKEN THERE.

<<<<<<< HEAD
Then enjoy these hot trash dots
=======
### Packages
Base
```
paru -S hyprland polkit-gnome bluez bluez-utils \
ffmpeg pavucontrol thunar sddm-git inotify-tools \
wl-clipboard cliphist grimblast-git playerctl \
thunar-archive-plugin alacritty swaylock-effects \
nwg-look-bin pamixer fish starship nm-connection-editor
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
>>>>>>> refs/remotes/origin/nixos
