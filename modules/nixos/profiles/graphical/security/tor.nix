{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.garden.system.security.tor;
in
{
  options.garden.system.security.tor.enable = mkEnableOption "Tor daemon";

  config.services.tor = mkIf cfg.enable {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
    torsocks.enable = true;
  };
}
