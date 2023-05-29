{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    #inputs.hyprpaper.packages.${pkgs.system}.hyprpaper
    brightnessctl
    polkit_gnome
    pamixer
    wl-clipboard
    wlsunset
    grim
    slurp
    swappy
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = builtins.readFile ../config/hypr/hyprland.conf;
  };
  xdg.configFile."hypr/hyprpaper.conf".text =
    builtins.readFile ../config/hypr/hyprpaper.conf;
  xdg.configFile."hypr/mocha.conf".text =
    builtins.readFile ../config/hypr/mocha.conf;
}
