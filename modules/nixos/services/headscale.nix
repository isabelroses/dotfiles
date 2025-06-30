{
  lib,
  self,
  config,
  inputs',
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  rdomain = config.networking.domain;

  cfg = config.garden.services.headscale;
in
{
  options.garden.services.headscale = mkServiceOption "headscale" {
    port = 8085;
    host = "0.0.0.0";
    domain = "hs.${rdomain}";
  };

  config = mkIf cfg.enable {
    garden.services = {
      postgresql.enable = true;
    };

    garden.packages = { inherit (config.services.headscale) package; };
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
            base_domain = rdomain;
            magic_dns = true;
            domains = [ cfg.domain ];
            nameservers = [ "9.9.9.9" ];
          };

          log.level = "warn";

          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];

          db_type = "postgres";
          db_host = "/run/postgresql";
          db_name = "headscale";
          db_user = "headscale";

          # TODO: logtail
          logtail.enabled = false;

          disable_check_updates = true;
        };
      };

      postgresql = {
        ensureDatabases = [ "headscale" ];
        ensureUsers = lib.singleton {
          name = "headscale";
          ensureDBOwnership = true;
        };
      };

      nginx.virtualHosts.${cfg.domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://${cfg.host}:${toString cfg.port}";
          proxyWebsockets = true;
        };

        locations."/web" = {
          root = "${inputs'.tgirlpkgs.packages.headscale-ui}/share";
        };
      };
    };
  };
}
