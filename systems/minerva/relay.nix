# hosts behind NAT name minerva as their relay in garden.fleet, so minerva
# serves their public services and proxies them over tailscale
{ lib, config, ... }:
let
  inherit (lib.attrsets) filterAttrs genAttrs mapAttrsToList;
  inherit (lib.lists) concatLists;

  relayed = filterAttrs (
    _: fleet: fleet.relay != null && fleet.relay.via == config.networking.hostName
  ) config.garden.fleet;

  # paths to cache here, so each one crosses the home uplink once
  cached = {
    # immich's thumbnails need a session, so nothing there is safe to share
    immich = [ ];
    # jellyfin's posters and thumbnails are public and most of a browse
    jellyfin = [ "~ ^/Items/.+/Images/" ];
  };

  # the port and domain come from the module defaults, which the relayed host
  # can't override without the relay-contract check failing
  vhost =
    host: name:
    let
      service = config.garden.services.${name};
      # the fleet name is the host's tailscale name
      upstream = "http://${host}:${toString service.port}";
    in
    {
      name = service.domain;
      value = {
        # these are media apps: big uploads, long streams
        extraConfig = ''
          client_max_body_size 0;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';

        locations = {
          "/" = {
            proxyPass = upstream;
            proxyWebsockets = true;
          };
        }
        // genAttrs (cached.${name} or [ ]) (_: {
          proxyPass = upstream;
          extraConfig = ''
            proxy_buffering on;
            proxy_cache static;
          '';
        });
      };
    };
in
{
  systemd.services.nginx = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
  };

  services.nginx.virtualHosts = lib.listToAttrs (
    concatLists (mapAttrsToList (host: fleet: map (vhost host) fleet.relay.services) relayed)
  );
}
