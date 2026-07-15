{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) map;
  inherit (lib.strings) optionalString;
  inherit (lib.options) mkOption;
  inherit (self.lib.services) mkServiceOption;
  inherit (self.lib.secrets) mkSecret;

  rdomain = config.networking.domain;
  cfg = config.garden.services.gatus;

  # gatus has no concept of a global default interval, so we apply one
  # (alongside some sane default conditions) to every endpoint below.
  # https://gatus.io/docs
  mkEndpoints = map (
    endpoint@{
      defaultConditions ? true,
      conditions ? [ ],
      ...
    }:
    {
      interval = "5m";
      conditions = if defaultConditions then ([ "[STATUS] == 200" ] ++ conditions) else conditions;
      alerts = [ { type = "discord"; } ];
    }
    // (removeAttrs endpoint [
      "defaultConditions"
      "conditions"
    ])
  );
in
{
  options.garden.services.gatus =
    mkServiceOption "gatus" {
      port = 3008;
      domain = "status.${rdomain}";
    }
    // {
      isPersonal = mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this is a personal deployment of gatus";
      };
    };

  config = mkIf cfg.enable {
    sops.secrets = {
      gatus-me = mkSecret {
        file = "gatus";
        key = "me";
      };

      gatus-tgc = mkSecret {
        file = "gatus";
        key = "tgc";
      };
    };

    services = {
      gatus = {
        enable = true;

        environmentFile =
          if cfg.isPersonal then config.sops.secrets.gatus-me.path else config.sops.secrets.gatus-tgc.path;

        settings = {
          web = {
            address = cfg.host;
            inherit (cfg) port;
          };

          ui = {
            title = if cfg.isPersonal then "status | isabel roses" else "status | tgirl.cloud";
            header = if cfg.isPersonal then "isabel's uptime" else "tgc's uptime";
            link = "https://${cfg.domain}";
            logo = optionalString cfg.isPersonal "https://isabelroses.com/me.webp";
            favicon.default = optionalString cfg.isPersonal "https://isabelroses.com/favicon.ico";
            default-sort-by = "group";
            custom-css = # css
              ''
                :root, :root.dark {
                  --background: 0 0% 0% !important;
                  --foreground: 226 64% 88% !important;
                  --card: 0 0% 0% !important;
                  --card-foreground: 226 64% 88% !important;
                  --popover: 237 16% 23% !important;
                  --popover-foreground: 226 64% 88% !important;
                  --primary: 199 76% 69% !important;
                  --primary-foreground: 0 0% 0% !important;
                  --secondary: 234 13% 31% !important;
                  --secondary-foreground: 226 64% 88% !important;
                  --muted: 237 16% 23% !important;
                  --muted-foreground: 228 24% 72% !important;
                  --accent: 199 76% 69% !important;
                  --accent-foreground: 0 0% 0% !important;
                  --destructive: 343 81% 75% !important;
                  --destructive-foreground: 0 0% 0% !important;
                  --border: 234 13% 31% !important;
                  --input: 234 13% 31% !important;
                  --ring: 199 76% 69% !important;
                }

                .bg-success,
                .bg-green-400, .bg-green-500, .bg-green-700 {
                  background-color: #a6e3a1 !important;
                }
                .bg-red-400, .bg-red-500, .bg-red-600, .bg-red-700 {
                  background-color: #f38ba8 !important;
                }
                .bg-yellow-400, .bg-yellow-500 {
                  background-color: #f9e2af !important;
                }

                .text-white.bg-green-400, .text-white.bg-green-500, .text-white.bg-green-700,
                .text-white.bg-red-400, .text-white.bg-red-500, .text-white.bg-red-600, .text-white.bg-red-700,
                .text-white.bg-yellow-400, .text-white.bg-yellow-500 {
                  color: #000 !important;
                }

                footer, #settings {
                  display: none !important;
                }
              '';
          };

          alerting.discord = {
            webhook-url = "$GATUS_DISCORD_WEBHOOK";
          };

          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/data.db";
          };

          # NOTE: these are monitored over their public URLs, so the domains
          # are hardcoded rather than derived from `networking.domain`.
          endpoints = mkEndpoints (if cfg.isPersonal then (import ./me.nix) else (import ./tgc.nix));
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
