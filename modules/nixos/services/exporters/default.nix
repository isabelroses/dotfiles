{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.lists) elem;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (self.lib) mkService;

  inherit (config.networking) hostName;
  inherit (config.garden) device fleet;

  registry = import ./registry.nix { inherit lib; };
  inherit (registry) endpoints;

  cfg = config.garden.services.exporters;
  services = config.garden.services;

  serves = name: cfg.enable && endpoints.${name}.when (fleet.${hostName} or { });

  rapl = elem device.cpu [
    "intel"
    "amd"
  ];

  exporter = name: {
    enable = true;
    inherit (endpoints.${name}) port;
  };
in
{
  imports = [ (mkService "exporters" { }) ];

  config = mkMerge [
    {
      garden.services.exporters.enable = mkDefault (
        fleet ? ${hostName} && registry.locate "prometheus" fleet services != null
      );
    }

    (mkIf (serves "node") {
      services.prometheus.exporters.node = exporter "node" // {
        enabledCollectors = [ "systemd" ];
      };
    })

    (mkIf (serves "node" && rapl) {
      users.groups.powercap = { };

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="powercap", RUN+="${pkgs.coreutils}/bin/chgrp powercap /sys%p/energy_uj", RUN+="${pkgs.coreutils}/bin/chmod g+r /sys%p/energy_uj"
      '';

      systemd.services.prometheus-node-exporter.serviceConfig.SupplementaryGroups = [ "powercap" ];
    })

    (mkIf (serves "nvidia-gpu") {
      services.prometheus.exporters.nvidia-gpu = exporter "nvidia-gpu";
    })

    (mkIf (serves "postgres") {
      services.prometheus.exporters.postgres = exporter "postgres" // {
        runAsLocalSuperUser = true;
      };
    })

    (mkIf (serves "redis") {
      services.prometheus.exporters.redis = exporter "redis" // {
        extraFlags = [
          "--redis.addr=redis://${services.redis.host}:${toString services.redis.port}"
          "--redis.password=${config.services.redis.servers.forgejo.requirePass}"
        ];
      };
    })

    (mkIf (serves "nginx") {
      services.prometheus.exporters.nginx = exporter "nginx";
    })

    (mkIf (serves "immich-api") {
      services.immich.environment = {
        IMMICH_TELEMETRY_INCLUDE = "api,io,job";
        IMMICH_API_METRICS_PORT = toString endpoints.immich-api.port;
        IMMICH_MICROSERVICES_METRICS_PORT = toString endpoints.immich-microservices.port;
      };
    })

    (mkIf (serves "synapse") {
      services.matrix-synapse.settings = {
        enable_metrics = true;
        listeners = [
          {
            inherit (endpoints.synapse) port;
            type = "metrics";
            bind_addresses = [ "0.0.0.0" ];
            tls = false;
            resources = [ ];
          }
        ];
      };
    })
  ];
}
