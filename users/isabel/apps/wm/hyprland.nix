{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: with lib; let
    cfg = config.isabel.hyprland;
in { 
  options.isabel.hyprland = {
    enable = mkEnableOption "enable hyprland";
    withNvidia = mkEnableOption "enable pc settings";
    onLaptop = mkEnableOption "enable laptop settings";
  };
  imports = [./hyprland-config.nix];
  home.packages = with pkgs; [
    #inputs.hyprpaper.packages.${pkgs.system}.hyprpaper
    inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
    brightnessctl
    wl-clipboard
    wlsunset
    grim
    slurp
    swappy
    wl-clipboard
    xdg-desktop-portal-hyprland
  ];
  wayland.windowManager = mkMerge [
    (mkIf cfg.enable {
      hyprland = {
        enable = true;
        systemdIntegration = true;
      };
    })
    (mkIf cfg.withNvidia {
      hyprland = {
        nvidiaPatches = true;
      };
    })
  ];
}
