{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;

  cfg = config.modules.services.headscale;
in {
  config = mkIf cfg.enable {
    environment.systemPackages = [config.services.headscale.package];

    services = {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;

        settings = {
          server_url = "https://hs.${domain}";

          dns_config = {
            override_local_dns = true;
            base_domain = domain;
            magic_dns = true;
            domains = ["hs.${domain}"];
            nameservers = [
              "1.1.1.1"
              "1.0.0.1"
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
        };
      };

      nginx.virtualHosts."hs.${domain}" =
        {
          locations."/" = {
            recommendedProxySettings = true;
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        }
        // lib.sslTemplate;
    };
  };
}
