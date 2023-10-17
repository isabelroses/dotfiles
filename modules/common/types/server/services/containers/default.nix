{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services;
in {
  virtualisation.oci-containers = {
    backend = "docker"; # podman hates this image

    containers = {
      "isabelroses-com" = lib.mkIf cfg.isabelroses-web.enable {
        image = "docker.io/isabelroses/isabelroses.com:latest";
        ports = ["3000:3000"];
        extraOptions = [
          "--pull=newer"
        ];
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
}
