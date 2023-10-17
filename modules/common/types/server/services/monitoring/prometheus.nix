{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.modules.services.monitoring.prometheus;
in {
  config = mkIf cfg.enable {
    services = {
      # Prometheus exporter for Grafana
      prometheus = {
        enable = true;
        port = 9100;
        # enabled exporters
        exporters = {
          node = {
            enable = true;
            port = 9101;
            enabledCollectors = [
              "logind"
              "systemd"
            ];
            disabledCollectors = [
              "textfile"
            ];
            openFirewall = true;
          };
        };
        scrapeConfigs = [
          {
            job_name = "test_job";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
              }
            ];
          }
        ];
      };
    };
  };
}
