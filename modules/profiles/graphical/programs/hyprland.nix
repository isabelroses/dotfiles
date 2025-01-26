{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;

  inherit (config.garden) meta;
in
{
  config = mkIf meta.hyprland {
    services.displayManager.sessionPackages = [ pkgs.hyprland ];
  };
}
