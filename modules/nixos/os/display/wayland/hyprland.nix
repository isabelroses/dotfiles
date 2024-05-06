{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;

  env = config.modules.environment;
in {
  config = mkIf (env.desktop == "Hyprland") {
    services.displayManager.sessionPackages = [pkgs.hyprland];
  };
}
