# freyja sits behind a home NAT, so minerva serves its public services and
# proxies them to it over tailscale
{ lib, config, ... }:
let
  # the module defaults, which freyja doesn't override
  inherit (config.garden.services) immich jellyfin;

  relay = port: cached: {
    # these are media apps: big uploads, long streams
    extraConfig = ''
      client_max_body_size 0;
      proxy_buffering off;
      proxy_request_buffering off;
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
    '';

    locations =
      let
        upstream = "http://${config.garden.fleet.freyja.tailscale}:${toString port}";
      in
      {
        "/" = {
          proxyPass = upstream;
          proxyWebsockets = true;
        };
      }
      # kept here so each one crosses the home uplink once
      // lib.attrsets.genAttrs cached (_: {
        proxyPass = upstream;
        extraConfig = ''
          proxy_buffering on;
          proxy_cache static;
        '';
      });
  };
in
{
  services.nginx.virtualHosts = {
    # immich's thumbnails need a session, so nothing there is safe to share
    "photos.isabelroses.com" = relay immich.port [ ];
    # jellyfin's posters and thumbnails are public and most of a browse
    "tv.isabelroses.com" = relay jellyfin.port [ "~ ^/Items/.+/Images/" ];
  };
}
