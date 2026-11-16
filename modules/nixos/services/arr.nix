{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib) mkService;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkIf;

  cfg = config.garden.services.arr;
in
{
  # garden.services is one attrsOf, so these can't be typed options here
  imports = [
    (mkService "arr" {
      # directory for storing media files managed by arr services
      mediaDir = "/media";
      # user and group that own the media and content directories
      mediaOwner = "root";
      mediaGroup = "media";
    })
    # inside its own mkIf, turning these on would recurse
    {
      garden.services = {
        jellyfin.enable = mkIf cfg.enable true;
        sonarr.enable = mkIf cfg.enable true;
        radarr.enable = mkIf cfg.enable true;
        prowlarr.enable = mkIf cfg.enable true;
        qbittorrent.enable = mkIf cfg.enable true;
      };
    }
  ];

  config = lib.modules.mkIf cfg.enable {
    users.groups.media = { };

    systemd.tmpfiles.settings."media-content-dirs" =
      genAttrs
        [
          "${cfg.mediaDir}/content"
          "${cfg.mediaDir}/content/tv"
          "${cfg.mediaDir}/content/movies"
          "${cfg.mediaDir}/content/home"

          "${cfg.mediaDir}/downloads"
          "${cfg.mediaDir}/downloads/tv"
          "${cfg.mediaDir}/downloads/movies"
        ]
        (_: {
          d = {
            mode = "0775";
            user = cfg.mediaOwner;
            group = cfg.mediaGroup;
          };
        });
  };
}
