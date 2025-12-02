{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.mpv = {
    enable = config.garden.profiles.graphical.enable && pkgs.stdenv.hostPlatform.isLinux;
  };

  garden.packages = lib.mkIf config.programs.mpv.enable {
    inherit (pkgs) syncplay;
  };
}
