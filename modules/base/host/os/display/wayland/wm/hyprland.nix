{
  config,
  lib,
  inputs',
  ...
}: let
  inherit (lib) mkIf isWayland;

  env = config.modules.environment;
in {
  # disables Nixpkgs Hyprland module to avoid conflicts
  disabledModules = ["programs/hyprland.nix"];

  config = mkIf (isWayland config && env.desktop == "Hyprland") {
    services.xserver.displayManager.sessionPackages = [inputs'.hyprland.packages.default];

    xdg.portal.configPackages = [
      inputs'.xdg-portal-hyprland.packages.xdg-desktop-portal-hyprland
    ];
  };
}
