{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self.lib) mkServiceOption mkSecret;

  cfg = config.garden.services.slskd;
in
{
  options.garden.services.slskd = mkServiceOption "slskd" {
    port = 3018;
    host = "0.0.0.0";
  };

  config = mkIf cfg.enable {
    sops.secrets.slskd = mkSecret {
      file = "slskd";
      key = "env";
    };

    services.slskd = {
      enable = true;
      openFirewall = true;

      group = "media";

      environmentFile = config.sops.secrets.slskd.path;

      domain = null;
      settings = {
        web = {
          inherit (cfg) port;
          ip_address = cfg.host;
        };

        permissions.file.mode = 775;

        directories = {
          incomplete = "/srv/storage/downloads/music";
          downloads = "/srv/storage/media/music";
        };

        shares.directories = [ "/srv/storage/media/music" ];
      };
    };
  };
}
