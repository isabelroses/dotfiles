# dotfiles-hypr

### Previews

<details>
<summary> Waybar </summary>

![[waybar](assets/waybar.png)](assets/waybar.png)
</details>

<details>
<summary> Eww Bar </summary>

![[eww-bar](assets/eww-bar.png)](assets/eww-bar.png)

<details>
<summary> Additional previews </summary>

![[quickmenu](assets/quickmenu.png)](assets/quickmenu.png)
![[swaync](assets/swaync.png)](assets/swaync.png)
![[datemenu](assets/datemenu.png)](assets/datemenu.png)
</details>

</details>

## Install

### Yay
Run as user NOT ROOT!
```bash
git clone https://aur.archlinux.org/yay-bin
cd yay-bin
makepkg -si
```

### Packages
Base
```
yay -S hyprland-bin polkit-gnome bluez bluez-utils \
ffmpeg viewnior swaync pavucontrol thunar \
wl-clipboard wf-recorder grimblast-git \ 
ffmpegthumbnailer playerctl noise-suppression-for-voice \
thunar-archive-plugin alacritty swaylock-effects \
sddm-git nwg-look-bin papirus-icon-theme pamixer \
rofi-lbonn-wayland-git wlogout fish \
```

Backgrounds (choose one or both `default is hyprpaper`)
```
yay -S swaybg
yay -S hyprpaper
```

Addons
```
yay -S ufw obsidian openvpn micro starship bellsym-git 
```

With waybar
```
yay -S  waybar-hyprland-git 
```

With eww
```
yay -S upower eww-wayland jaq socat gjs coreutils
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