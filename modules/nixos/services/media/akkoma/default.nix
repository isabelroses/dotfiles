{
  lib,
  pkgs,
  self',
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit ((pkgs.formats.elixirConf {}).lib) mkRaw mkMap;

  rdomain = config.networking.domain;
  cfg = config.modules.services.media.akkoma;
in {
  config = mkIf cfg.enable {
    services.akkoma = {
      enable = true;
      extraPackages = with pkgs; [ffmpeg exiftool imagemagick];

      extraStatic = {
        "static/terms-of-service.html" =
          pkgs.writeText "terms-of-service.html" "Just be normal please";

        "favicon.png" = pkgs.fetchurl {
          url = "https://avatars.githubusercontent.com/u/71222764?v=4";
          sha256 = "sha256-abbhpAHbCVA65fJut4N3tCc0Z9cwSCnnVNyFjpr57ig=";
        };

        "emoji/blobs" = pkgs.akkoma-emoji.blobs_gg;
        "emoji/zerotwo" = self'.packages.zerotwo-emojis;
        "emoji/jumpies" = self'.packages.jumpies-emojis;
      };

      config = {
        ":pleroma"."Pleroma.Web.Endpoint".url.host = cfg.domain;

        ":pleroma".":instance" = {
          name = "not localhost";
          description = "Isabel Roses' akkoma instance";
          email = "isabel@isabelroses.com";
          notify_email = "noreply@isabelroses.com";

          languages = ["en"];

          registrations_open = false;
          invites_enabled = true;

          admin_privileges = [
            "users_read"
            "users_manage_invites"
            "users_manage_activation_state"
            "users_manage_tags"
            "users_manage_credentials"
            "users_delete"
            "reports_manage_reports"
            "moderation_log_read"
            "statistics_read"
          ];

          federating = true;

          limit = 69420;
          remote_limit = 100000;
          max_pinned_statuses = 5;
          max_account_fields = 100;

          upload_limit = 41943040; # 40Mb

          limit_to_local_content = mkRaw ":unauthenticated";
          healthcheck = true;
          cleanup_attachments = true;
          allow_relay = true;
          safe_dm_mentions = true;
          external_user_synchronization = true;
        };

        # going to setup prometheus later
        ":prometheus"."Pleroma.Web.Endpoint.MetricsExporter" = {
          enabled = true;
          auth = false;
          format = mkRaw ":text";
          path = "/api/pleroma/app_metrics";
        };

        ":pleroma".":mrf".policies =
          map mkRaw ["Pleroma.Web.ActivityPub.MRF.SimplePolicy"];

        # we configure from nix
        ":pleroma".":configurable_from_database" = false;

        ":pleroma"."Pleroma.Captcha".enabled = false;

        ":pleroma".":mrf_simple" = let
          blocklist = import ./blocklist.nix;
        in {
          media_nsfw = mkMap blocklist.media_nsfw;
          reject = mkMap blocklist.reject;
          followers_only = mkMap blocklist.followers_only;
        };
      };

      nginx = {
        useACMEHost = rdomain;
        forceSSL = true;
      };
    };
  };
}
