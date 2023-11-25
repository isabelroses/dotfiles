{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services;
  inherit (config.networking) domain;
  inherit (lib) mkIf sslTemplate;
in {
  config = mkIf cfg.isabelroses-web.enable {
    virtualisation.oci-containers = {
      backend = "docker"; # podman hates this image

      containers = {
        "isabelroses-com" = {
          image = "docker.io/isabelroses/isabelroses.com:latest";
          ports = ["3000:3000"];
          environmentFiles = [
            config.sops.secrets.isabelroses-web-env.path
          ];
          login = {
            registry = "docker.io";
            username = "isabelroses";
            passwordFile = config.sops.secrets.docker-hub.path;
          };
        };
      };
    };

    services.nginx.virtualHosts.${domain} =
      {
        locations."/".proxyPass = "http://127.0.0.1:3000";
      }
      // sslTemplate;
  };
}
