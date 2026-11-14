{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (self.lib) mkServiceOption;

  cfg = config.garden.services.jellyfin;
in
{
  options.garden.services.jellyfin =
    mkServiceOption "jellyfin" {
      # jellyfin's own default; nixpkgs can't set its port or bind address, it
      # always listens on every interface
      port = 8096;
      host = null;
      domain = "tv.${config.networking.domain}";
    }
    // {
      httpsPort = mkOption {
        type = lib.types.port;
        default = 8920;
        readOnly = true;
        description = "jellyfin's https port, which like its http port can't be set here";
      };
    };

  config = mkIf config.garden.services.jellyfin.enable {
    # the web port plus jellyfin's https and client discovery ports
    networking.firewall = {
      allowedTCPPorts = [
        cfg.port
        cfg.httpsPort
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
