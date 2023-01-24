!#/bin/bash

read -p 'Username: ' uservar

chmod +x ./install-starship.sh
./install-starship.sh

ln -sf ./.local/share/icons/ .icons
ln -sf ./.local/share/fonts/ .fonts
ln -sf ./.local/share/themes/ .themes

ln -f ./.local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark/gtk-4.0/gtk.css ./.config/gtk-4.0/gtk.css
ln -f ./.local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark/gtk-4.0/gtk-dark.css ./.config/gtk-4.0/gtk-dark.css
ln -sf ./.local/share/themes/Catppuccin-Mocha-Standard-Blue-Dark/gtk-4.0/assets ./.config/gtk-4.0/assets

gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha-Standard-Blue-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface cursor-theme "Catppuccin-Mocha-Blue-Cursor"
gsettings set org.gnome.desktop.interface font-name "./.fonts/Roboto Mono nerd font regular 13"
gsettings set org.gnome.desktop.interface document-font-name "./.fonts/Roboto Mono nerd font regular 13"
gsettings set org.gnome.desktop.interface monospace-font-name "./.fonts/Roboto Mono nerd font regular 13"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "./.fonts/Roboto Mono nerd font regular 13"

gsettings set org.gnome.desktop.wm.preferences theme "Catppuccin-Mocha-Standard-Blue-Dark"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface enable-hot-corners true


gsettings set org.gnome.desktop.interface clock-format "12h"

gsettings set org.gnome.desktop.background picture-uri "file:///home/$uservar/.local/share/backgrounds/wall.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$uservar/.local/share/backgrounds/wall.png"
gsettings set org.gnome.desktop.background picture-options "zoom"
