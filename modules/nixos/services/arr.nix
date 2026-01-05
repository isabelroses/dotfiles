{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    genAttrs
    ;

  cfg = config.garden.services.arr;
in
{
  options.garden.services.arr = {
    enable = mkEnableOption "arr services";

    mediaDir = mkOption {
      type = types.str;
      default = "/media";
      description = "Directory for storing media files managed by arr services";
    };

    contentDir = mkOption {
      type = types.str;
      default = "${cfg.mediaDir}/content";
      defaultText = "\${cfg.mediaDir}/content";
      description = "Directory for storing application data for arr services";
    };

    mediaOwner = mkOption {
      type = types.str;
      default = "root";
      description = "User that owns the media and content directories";
    };

    mediaGroup = mkOption {
      type = types.str;
      default = "media";
      description = "Group that owns the media and content directories";
    };

    openFirewall = mkEnableOption "open the firewall for the arr services" // {
      default = true;
      defaultText = "true";
    };
  };

  config = lib.mkIf cfg.enable {
    garden.services = {
      jellyfin.enable = true;
      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
      transmission.enable = true;
    };

    users.groups.media = { };

    systemd.tmpfiles.settings = {
      "media-content-dirs" =
        genAttrs
          [
            "${cfg.mediaDir}/content"
            "${cfg.mediaDir}/content/tv"
            "${cfg.mediaDir}/content/movies"
            "${cfg.mediaDir}/content/home"
          ]
          (_: {
            d = {
              mode = "0775";
              user = cfg.mediaOwner;
              group = cfg.mediaGroup;
            };
          });

      "media-downloads-dirs" =
        genAttrs
          [
            "${cfg.mediaDir}/downloads"
            "${cfg.mediaDir}/downloads/incomplete"
            "${cfg.mediaDir}/downloads/watch"
            "${cfg.mediaDir}/downloads/sonarr"
            "${cfg.mediaDir}/downloads/radarr"
          ]
          (_: {
            d = {
              mode = "0755";
              user = "transmission";
              group = "media";
            };
          });
    };
  };
}
