{ lib }:
let
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.lists) elem findFirst;
  inherit (lib.trivial) defaultTo;

  runs = service: fleet: fleet.services.${service}.enable or false;
in
{
  endpoints = {
    node = {
      port = 9100;
      when = _: true;
    };

    # per-container metrics on hosts that run docker; unmanaged ones run it
    # from their compose stack
    cadvisor = {
      port = 9338;
      when = fleet: fleet.docker or false;
    };

    nvidia-gpu = {
      port = 9835;
      when = fleet: fleet.device.gpu or null == "nvidia";
    };

    postgres = {
      port = 9187;
      when = runs "postgresql";
    };

    redis = {
      port = 9121;
      when = runs "redis";
    };

    nginx = {
      port = 9113;
      when = runs "nginx";
    };

    immich-api = {
      port = 8091;
      when = runs "immich";
    };

    immich-microservices = {
      port = 8092;
      when = runs "immich";
    };

    synapse = {
      port = 9000;
      path = "/_synapse/metrics";
      when = runs "matrix";
    };

    sonarr = {
      port = 9708;
      when = runs "arr";
    };

    radarr = {
      port = 9709;
      when = runs "arr";
    };

    prowlarr = {
      port = 9710;
      when = runs "arr";
    };

    # qui's own metrics server, which also reports on the qbittorrent behind it
    qui = {
      port = 9074;
      when = runs "arr";
    };

    # nginx in front of forgejo's unix socket, reachable over tailscale only
    forgejo = {
      port = 9711;
      when = runs "forgejo";
    };

    # tailscaled's web client
    tailscale = {
      port = 5252;
      when = _: true;
    };

    # nginx in front of gatus, whose metrics share its web port
    gatus = {
      port = 9712;
      when = runs "gatus";
    };
  };

  # unmanaged hosts run their exporters themselves, at these same ports
  hostsWhere =
    when: fleet:
    attrNames (
      filterAttrs (
        _: host:
        elem host.class [
          "nixos"
          "unmanaged"
        ]
        && when host
      ) fleet
    );

  locate =
    service: fleet: defaults:
    let
      host = findFirst (host: runs service fleet.${host}) null (attrNames fleet);
    in
    if host == null then
      null
    else
      {
        inherit host;
        port = defaultTo defaults.${service}.port (fleet.${host}.services.${service}.port or null);
      };
}
