{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.jellyfin;
  branding =
    pkgs.runCommandLocal "jellyfin-branding.xml"
      {
        css = pkgs.replaceVars ./theme.css {
          inherit (self.lib.palette)
            accent
            base
            surface
            overlay
            ;
        };
      }
      ''
        esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$1"; }

        cat > $out <<EOF
        <?xml version="1.0" encoding="utf-8"?>
        <BrandingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
          <LoginDisclaimer>$(esc ${./login.html})</LoginDisclaimer>
          <CustomCss>$(esc "$css")</CustomCss>
          <SplashscreenEnabled>false</SplashscreenEnabled>
        </BrandingOptions>
        EOF
      '';
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

    systemd.services.jellyfin.serviceConfig.ExecStartPre = [
      "${pkgs.coreutils}/bin/install -m 600 ${branding} ${config.services.jellyfin.configDir}/branding.xml"
    ];

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
