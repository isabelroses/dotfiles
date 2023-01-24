#!/bin/sh

echo "Copy Theme Mocha"
cp -r ~/.local/bin/scripts/Setups/Spicetify_Installers/Themes/catppuccin-mocha ~/.config/spicetify/Themes

echo "Copy extension mocha to spicetify"
cp ~/.local/bin/scripts/Setups/Spicetify_Installers/Extensions/catppuccin-mocha.js ~/.config/spicetify/Extensions

echo "Exec spicetify config and apply"
spicetify config current_theme catppuccin-mocha
spicetify config color_scheme blue
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
spicetify config extensions catppuccin-mocha.js
spicetify backup apply
