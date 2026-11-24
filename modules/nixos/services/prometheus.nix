{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) filter optional;
  inherit (lib.modules) mkIf;
  inherit (self.lib) mkSecret mkService;

  inherit (config.networking) hostName;

  cfg = config.garden.services.prometheus;
  services = config.garden.services;
  homeAssistant = services.home-assistant;

  registry = import ./exporters/registry.nix { inherit lib; };

  job =
    name:
    {
      port,
      when,
      path ? "/metrics",
      # bare names hit 127.0.0.2 on the prometheus host
      tailnetOnly ? false,
    }:
    {
      job_name = name;
      metrics_path = path;
      static_configs = map (host: {
        targets = [
          "${
            if tailnetOnly then "${host}.${config.garden.system.networking.tailscale.tailnet}" else host
          }:${toString port}"
        ];
        labels.host = host;
      }) (registry.hostsWhere when config.garden.fleet);
    };

  local = name: port: {
    job_name = name;
    static_configs = [
      {
        targets = [ "127.0.0.1:${toString port}" ];
        labels.host = hostName;
      }
    ];
  };
in
{
  imports = [
    (mkService "prometheus" { port = 9090; })
  ];

  config = mkIf cfg.enable {
    sops.secrets.prometheus-home-assistant-token = mkIf homeAssistant.enable (mkSecret {
      file = "monitoring";
      key = "home-assistant-token";
      owner = "prometheus";
    });

    services.prometheus = {
      enable = true;
      listenAddress = cfg.host;
      inherit (cfg) port;

      retentionTime = "1y";
      extraFlags = [ "--storage.tsdb.retention.size=50GB" ];

      checkConfig = "syntax-only";

      globalConfig.scrape_interval = "30s";

      scrapeConfigs =
        filter (j: j.static_configs != [ ]) (mapAttrsToList job registry.endpoints)
        ++ [ (local "prometheus" cfg.port) ]
        ++ optional services.loki.enable (local "loki" services.loki.port)
        ++ optional homeAssistant.enable (
          local "home-assistant" homeAssistant.port
          // {
            metrics_path = "/api/prometheus";
            scrape_interval = "15s";
            authorization.credentials_file = config.sops.secrets.prometheus-home-assistant-token.path;
          }
        );
    };
  };
}
