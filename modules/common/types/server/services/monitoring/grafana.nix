{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (config.networking) domain;

  cfg = config.modules.services.monitoring.grafana;

  port = 3100;
in {
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [port];

    services.grafana = {
      enable = true;
      dataDir = "/srv/storage/grafana";

      settings = {
        analytics = {
          reporting_enabled = false;
          check_for_updates = false;
        };

        server = {
          # Listening address and TCP port
          http_port = port;
          # Grafana needs to know on which domain and URL it's running on:
          http_addr = "127.0.0.1";
          domain = "graph.${domain}";

          # true means HTTP compression is enabled
          enable_gzip = true;
        };

        smtp = let
          mailer = "grafana@${domain}";
        in {
          enabled = true;

          user = mailer;
          password = "$__file{" + config.sops.secrets.mailserver-grafana-nohash.path + "}";

          host = "mail.${domain}:465";
          from_address = mailer;
          startTLS_policy = "MandatoryStartTLS";
        };
      };
    };
  };
}
