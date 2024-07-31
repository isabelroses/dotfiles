{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.hardware) ldTernary;
in
{
  programs.nh = {
    enable = true;

    clean = {
      enable = !config.nix.gc.automatic;
    } // ldTernary pkgs { dates = "daily"; } { interval = "daily"; };
  };
}
