{
  config,
  lib,
  self',
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;

  cfg = config.modules.services.headscale;
in {
  config = mkIf cfg.enable {
    environment.systemPackages = [config.services.headscale.package];

    networking.firewall = {
      allowedUDPPorts = [config.services.headscale.port];
    };

    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;

        settings = {
          server_url = "https://hs.${domain}";

          dns_config = {
            override_local_dns = true;
            base_domain = "${domain}";
            magic_dns = true;
            domains = ["hs.${domain}"];
            nameservers = [
              "9.9.9.9"
            ];
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

      nginx.virtualHosts."hs.${domain}" =
        {
          locations."/" = {
            recommendedProxySettings = true;
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };

          locations."/web" = {
            root = "${self'.packages.headscale-ui}/share";
          };
        }
        // lib.sslTemplate;
    };
  };
}
