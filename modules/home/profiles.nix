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
      ;

    server = {
      inherit (cfg.server) enable;
      oracle.enable = cfg.server.oracle.enable;
      hetzner.enable = cfg.server.hetzner.enable;
    };
  };

  programs.git.enable = lib.mkDefault cfg.workstation.enable;
}
