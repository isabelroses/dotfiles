{
  lib,
  config,
  inputs',
  ...
}: let
  inherit (lib) mkIf;

  env = config.modules.environment;
in {
  # disables Nixpkgs Hyprland module to avoid conflicts
  disabledModules = ["programs/hyprland.nix"];

  config = mkIf (env.desktop == "Hyprland") {
    services.xserver.displayManager.sessionPackages = [inputs'.hyprland.packages.default];
  };
}
