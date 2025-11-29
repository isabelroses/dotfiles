{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.mpv = {
    inherit (config.garden.profiles.graphical) enable;
  };

  garden.packages = lib.mkIf config.programs.mpv.enable {
    inherit (pkgs) syncplay;
  };
}
