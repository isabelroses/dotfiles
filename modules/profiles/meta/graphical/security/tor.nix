{ lib, config, ... }:
{
  services.tor = lib.mkIf config.modules.system.security.tor.enable {
    enable = true;
    client.enable = true;
    client.dns.enable = true;
    torsocks.enable = true;
  };
}
