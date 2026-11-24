{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.lists) elem;
  inherit (lib.modules)
    mkDefault
    mkForce
    mkIf
    mkMerge
    ;
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

  # for apps that serve /metrics only beside their public site: nginx hands
  # it to prometheus on the endpoint's port, which only tailscale (a trusted
  # interface) reaches, and hides it from the public vhost
  bridge = name: upstream: {
    services.nginx.virtualHosts = {
      ${services.${name}.domain}.locations."= /metrics".return = "404";

      "${name}-metrics" = {
        listen =
          map
            (addr: {
              inherit addr;
              inherit (endpoints.${name}) port;
            })
            [
              "0.0.0.0"
              "[::]"
            ];
        quic = false;
        forceSSL = false;
        enableACME = false;
        securityHeaders = false;
        locations."= /metrics".proxyPass = upstream;
      };
    };
  };

  # exportarr takes the api key from the app's own config.xml. loading it as a
  # credential lets root read it, since prowlarr's lives under the 0700
  # /var/lib/private. the port isn't in there: nixos sets it through the env
  exportarr = name: {
    services.prometheus.exporters."exportarr-${name}" = exporter name // {
      url = "http://127.0.0.1:${toString services.${name}.port}";
      environment.CONFIG = "%d/config.xml";
    };

    systemd.services."prometheus-exportarr-${name}-exporter".serviceConfig.LoadCredential =
      mkForce "config.xml:${config.services.${name}.dataDir}/config.xml";
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

    (mkIf (serves "tailscale" && config.garden.system.networking.tailscale.enable) {
      services.tailscale.extraSetFlags = [ "--webclient" ];
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

    (mkIf (serves "sonarr") (exportarr "sonarr"))
    (mkIf (serves "radarr") (exportarr "radarr"))
    (mkIf (serves "prowlarr") (exportarr "prowlarr"))

    (mkIf (serves "qui") {
      services.qui.settings = {
        metricsEnabled = true;
        metricsHost = "0.0.0.0";
        metricsPort = endpoints.qui.port;
      };
    })

    (mkIf (serves "forgejo") (mkMerge [
      { services.forgejo.settings.metrics.ENABLED = true; }
      (bridge "forgejo" "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}")
    ]))

    (mkIf (serves "gatus") (mkMerge [
      { services.gatus.settings.metrics = true; }
      (bridge "gatus" "http://${services.gatus.host}:${toString services.gatus.port}")
    ]))

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
