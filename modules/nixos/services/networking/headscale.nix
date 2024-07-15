{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (lib) template;
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;

  rdomain = config.networking.domain;

  cfg = config.garden.services.networking.headscale;
in
{
  options.garden.services.networking.headscale = mkServiceOption "headscale" {
    port = 8085;
    host = "0.0.0.0";
    domain = "hs.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      networking.nginx.enable = true;
      database.postgresql.enable = true;
    };

    environment.systemPackages = [ config.services.headscale.package ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    services = {
      headscale = {
        enable = true;
        address = cfg.host;
        inherit (cfg) port;

        settings = {
          server_url = cfg.domain;

          dns_config = {
            override_local_dns = true;
            base_domain = "${rdomain}";
            magic_dns = true;
            domains = [ "${cfg.domain}" ];
            nameservers = [ "9.9.9.9" ];
          };

          log = {
            level = "warn";
          };

          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];

          db_type = "postgres";
          db_host = "/run/postgresql";
          db_name = "headscale";
          db_user = "headscale";

          # TODO: logtail
          logtail = {
            enabled = false;
          };

          disable_check_updates = true;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:${toString cfg.port}";
          proxyWebsockets = true;
        };

        locations."/web" = {
          root = "${inputs'.beapkgs.packages.headscale-ui}/share";
        };
      } // template.ssl rdomain;
    };
  };
}
