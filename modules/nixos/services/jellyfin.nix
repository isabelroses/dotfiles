{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.jellyfin;
in
{
  imports = [
    (mkService "jellyfin" {
      port = 8096;
      host = null;
      domain = "tv.${config.networking.domain}";
    })
  ];

  config = mkIf config.garden.services.jellyfin.enable {
    # the web port plus jellyfin's client discovery ports
    networking.firewall = {
      allowedTCPPorts = [
        cfg.port
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
    };
  };
}
