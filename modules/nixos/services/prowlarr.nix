{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.prowlarr;
in
{
  imports = [
    (mkService "prowlarr" {
      port = 3022;
      host = "0.0.0.0";
    })
  ];

  config = mkIf config.garden.services.prowlarr.enable {
    services.prowlarr = {
      enable = true;
      settings.server = {
        inherit (cfg) port;
        bindaddress = cfg.host;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.prowlarr.serviceConfig = {
      User = "prowlarr";
      Group = "media";
    };
  };
}
