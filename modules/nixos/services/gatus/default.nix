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
  inherit (self.lib) mkSecret mkService;

  p = self.lib.palette;
  inherit (p) hsl;

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
  imports = [
    (mkService "gatus" {
      port = 3008;
      domain = "status.${rdomain}";
      isPersonal = true;
    })
  ];

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
                  --background: ${hsl.base} !important;
                  --foreground: ${hsl.text} !important;
                  --card: ${hsl.base} !important;
                  --card-foreground: ${hsl.text} !important;
                  --popover: ${hsl.surface} !important;
                  --popover-foreground: ${hsl.text} !important;
                  --primary: ${hsl.accent} !important;
                  --primary-foreground: ${hsl.textOnAccent} !important;
                  --secondary: ${hsl.overlay} !important;
                  --secondary-foreground: ${hsl.text} !important;
                  --muted: ${hsl.surface} !important;
                  --muted-foreground: ${hsl.textMuted} !important;
                  /* shadcn's accent is the hover fill, not the brand colour */
                  --accent: ${hsl.overlay} !important;
                  --accent-foreground: ${hsl.text} !important;
                  --destructive: ${hsl.red} !important;
                  --destructive-foreground: ${hsl.textOnAccent} !important;
                  --border: ${hsl.border} !important;
                  --input: ${hsl.border} !important;
                  --ring: ${hsl.accent} !important;
                }

                .bg-success,
                .bg-green-400, .bg-green-500, .bg-green-700 {
                  background-color: ${p.green} !important;
                }
                .bg-red-400, .bg-red-500, .bg-red-600, .bg-red-700 {
                  background-color: ${p.red} !important;
                }
                .bg-yellow-400, .bg-yellow-500 {
                  background-color: ${p.yellow} !important;
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
