{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
in
{
  services.tor = mkIf config.garden.system.security.tor.enable {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
    torsocks.enable = true;
  };
}
