{
  lib,
  self,
  pkgs,
  config,
  inputs',
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  inherit ((pkgs.formats.elixirConf { }).lib) mkRaw mkMap;

  rdomain = config.networking.domain;
  cfg = config.garden.services.akkoma;
in
{
  options.garden.services.akkoma = mkServiceOption "akkoma" { domain = "akko.${rdomain}"; };

  config = mkIf cfg.enable {
    services = {
      akkoma = {
        enable = true;
        extraPackages = builtins.attrValues { inherit (pkgs) ffmpeg exiftool imagemagick; };

        extraStatic = {
          "static/terms-of-service.html" = pkgs.writeText "terms-of-service.html" "Just be normal please";

          "favicon.png" = pkgs.fetchurl {
            url = "https://gravatar.com/avatar/c487c810e09878b4bd90df713a7c9523?size=512";
            hash = "sha256-jexv4k2YnM3i2a9RZZRrHKGBpH8V7EQpjKwLJOuMi2A=";
          };

          "emoji/blobs" = pkgs.blobs_gg;
          "emoji/awesome" = inputs'.tgirlpkgs.packages.emojis;
        };

        config = {
          ":pleroma"."Pleroma.Web.Endpoint".url.host = cfg.domain;
          ":pleroma"."Pleroma.Upload".base_url = "https://${cfg.domain}:443/media";

          ":pleroma".":instance" = {
            name = "not localhost";
            description = "Isabel Roses' akkoma instance";
            email = "isabel@isabelroses.com";
            notify_email = "noreply@isabelroses.com";

            languages = [ "en" ];

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

          ":pleroma".":mrf".policies = map mkRaw [ "Pleroma.Web.ActivityPub.MRF.SimplePolicy" ];

          # we configure from nix
          ":pleroma".":configurable_from_database" = false;

          ":pleroma"."Pleroma.Captcha".enabled = false;

          ":pleroma".":mrf_simple".blocklist = builtins.mapAttrs (_: mkMap) (import ./blocklist.nix);
        };

        nginx = {
          useACMEHost = rdomain;
          forceSSL = true;
          quic = true;
        };
      };

      postgresql = {
        ensureDatabases = [ "akkoma" ];
        ensureUsers = lib.singleton {
          name = "akkoma";
          ensureDBOwnership = true;
        };
      };
    };
  };
}
