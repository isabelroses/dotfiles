{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;
  cfg = config.modules.services.dns.nextdns;
in {
  services = mkIf cfg.enable {
    adguardhome = {
      enable = true;
    };
    nginx.virtualHosts."dns.${domain}".locations."/".proxyPass = "http://127.0.0.1:5353";
  };
}
