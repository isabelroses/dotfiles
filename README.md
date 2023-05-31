# Littral Trash

Still just learning nix. However if you are desprate enough to install this:

```bash
git clone -b nixos https://github.com/isabelroses/dotfiles .setup
cd .setup
sudo nixos-rebuild switch --flake .#hydra
```
NOTE: THIS WILL NOT RUN UNLESS YOU EITHER REMOVE THE CLOUDFLARED MODLUES OR CREATE AND `env.nix` FILE AND HAVE A CLOUDFLARED TOKEN THERE.

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
```

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

