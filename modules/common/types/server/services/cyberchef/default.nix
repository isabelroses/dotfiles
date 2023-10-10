{
  self,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
in {
  services.nginx.virtualHosts."chef.${domain}" = lib.mkIf config.modules.services.cyberchef.enable {
    default = true;
    forceSSL = true;
    enableACME = true;
    listen = [
      {
        ssl = false;
        port = 8000;
        addr = "127.0.0.1";
      }
    ];
    root = self.packages.${pkgs.hostPlatform.system}.cyberchef;
  };
  networking.firewall.allowedTCPPorts = [8000];
}
