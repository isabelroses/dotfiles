# a host behind NAT names its relay in garden.fleet, and the relay serves its
# public services by proxying them to it over tailscale
{ lib, config, ... }:
let
  inherit (lib.attrsets)
    filterAttrs
    genAttrs'
    mapAttrsToList
    nameValuePair
    ;
  inherit (lib.lists) concatLists;
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) defaultTo;

  inherit (config.networking) hostName;

  # the hosts that name this one as their relay
  relayed = filterAttrs (_: fleet: hostName == fleet.relay.via or null) config.garden.fleet;

  # each service as the host runs it: what its fleet entry sets, else the module default
  served = concatLists (
    mapAttrsToList (
      host: fleet:
      map (
        name:
        let
          set = fleet.services.${name} or { };
          defaults = config.garden.services.${name};
        in
        {
          inherit host name;
          enable = set.enable or false;
          port = defaultTo defaults.port (set.port or null);
          domain = defaultTo defaults.domain (set.domain or null);
        }
      ) fleet.relay.services
    ) relayed
  );

  vhost =
    service:
    nameValuePair service.domain {
      # room for media apps, which relayed services often are: big uploads,
      # long streams
      extraConfig = ''
        client_max_body_size 0;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
      '';

      locations."/" = {
        # the fleet name is the host's tailscale name
        proxyPass = "http://${service.host}:${toString service.port}";
        proxyWebsockets = true;
      };
    };
in
{
  config = mkIf (relayed != { }) {
    assertions = map (service: {
      assertion = service.enable;
      message = "${service.host} relays ${service.name} through ${hostName} but doesn't enable it in systems/fleet.toml";
    }) served;

    systemd.services.nginx = {
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
    };

    services.nginx.virtualHosts = genAttrs' served vhost;
  };
}
