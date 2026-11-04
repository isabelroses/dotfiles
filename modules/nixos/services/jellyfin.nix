{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.jellyfin;
in
{
  options.garden.services.jellyfin = mkServiceOption "jellyfin" {
    port = 8096;
    domain = "tv.${config.networking.domain}";
  };

  config = mkIf config.garden.services.jellyfin.enable {
    # the web port plus jellyfin's https and client discovery ports
    garden.networking.lan = {
      allowedTCPPorts = [
        cfg.port
        8920
      ];
      allowedUDPPorts = [
        1900
        7359
      ];
    };

    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    services = {
      jellyfin = {
        enable = true;
        dataDir = "/srv/storage/jellyfin";
        group = "media";

        hardwareAcceleration = {
          enable = true;
          type = "nvenc";
          device = "/dev/dri/renderD128";
        };

        transcoding = {
          hardwareDecodingCodecs = {
            h264 = true;
            hevc = true;
            hevc10bit = true;
            hevcRExt10bit = true;
            hevcRExt12bit = true;
            mpeg2 = true;
            vc1 = true;
            vp8 = true;
            vp9 = true;
          };

          hardwareEncodingCodecs.hevc = true;
        };
      };

      cloudflared.tunnels.${config.networking.hostName} = {
        ingress.${cfg.domain} = "http://${cfg.host}:${toString cfg.port}";
      };
    };
  };
}
