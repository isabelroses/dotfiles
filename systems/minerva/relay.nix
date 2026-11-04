# freyja sits behind a home NAT, so minerva serves its public services and
# proxies them to it over tailscale
{ config, ... }:
let
  # the module defaults, which freyja doesn't override
  inherit (config.garden.services) immich jellyfin;

  relay = port: {
    # these are media apps: big uploads, long streams
    extraConfig = ''
      client_max_body_size 0;
      proxy_buffering off;
      proxy_request_buffering off;
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
    '';

    locations."/" = {
      proxyPass = "http://${config.garden.fleet.freyja.tailscale}:${toString port}";
      proxyWebsockets = true;
    };
  };
in
{
  services.nginx.virtualHosts = {
    "photos.isabelroses.com" = relay immich.port;
    "tv.isabelroses.com" = relay jellyfin.port;
  };
}
