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

          redis = {
            enable = true;
            openFirewall = true;
            port = 9102;
          };

          postgres = {
            enable = true;
            openFirewall = true;
            port = 9103;
          };
        };

        scrapeConfigs = [
          {
            job_name = "prometheus";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9100"];}];
          }
          {
            job_name = "node";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9101"];}];
          }
          {
            job_name = "redis_exporter";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9102"];}];
          }
          {
            job_name = "postgres";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9103"];}];
          }
        ];
      };
    };
  };
}
