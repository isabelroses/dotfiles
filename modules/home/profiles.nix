{ lib, osConfig, ... }:
let
  cfg = osConfig.garden.profiles;
in
{
  garden.profiles = {
    inherit (cfg)
      graphical
      headless
      workstation
      laptop
      server
      ;
  };

  programs.git.enable = lib.mkDefault cfg.workstation.enable;
}
