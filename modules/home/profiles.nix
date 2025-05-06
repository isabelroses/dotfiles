{ osConfig, ... }:
let
  cfg = osConfig.garden.profiles;
in
{
  garden.profiles = {
    inherit (cfg)
      graphical
      headless
      workstation
      gaming
      laptop
      ;

    # we don't inherit these as there is extra options here
    server = {
      inherit (cfg.server) enable;
      oracle.enable = cfg.server.oracle.enable;
      hetzner.enable = cfg.server.hetzner.enable;
    };
  };
}
