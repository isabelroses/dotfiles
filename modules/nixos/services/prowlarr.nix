{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.prowlarr;
in
{
  options.garden.services.prowlarr = mkServiceOption "prowlarr" {
    port = 3022;
  };

  config = mkIf config.garden.services.prowlarr.enable {
    services.prowlarr = {
      enable = true;
      inherit (config.garden.services.arr) openFirewall;
      settings.server.port = cfg.port;
    };

    systemd.services.prowlarr.serviceConfig = {
      User = "prowlarr";
      Group = "media";
    };
  };
}
