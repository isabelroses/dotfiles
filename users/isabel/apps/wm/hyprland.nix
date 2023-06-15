{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: with lib; let
  cfg = config.isabel.desktop.hyprland;
  inherit (lib) mkEnableOption mkIf mkMerge;
in { 
  options.isabel.desktop.hyprland = {
    enable = mkEnableOption "enable hyprland";
    isNvidia = mkEnableOption "enable pc settings";
    isLaptop = mkEnableOption "enable laptop settings";
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
    xdg-desktop-portal-hyprland
  ];
  wayland.windowManager = mkMerge [
    (mkIf cfg.enable {
      hyprland = {
        enable = true;
        systemdIntegration = true;
      };
    })
    (mkIf cfg.isNvidia {
      hyprland = {
        nvidiaPatches = true;
      };
    })
  ];
  xdg.portal = {
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
