{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;

  env = config.garden.environment;
in
{
  config = mkIf (env.desktop == "Hyprland") {
    services.displayManager.sessionPackages = [ pkgs.hyprland ];
  };
}
