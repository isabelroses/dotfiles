{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services;
in {
  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      "isabelroses-com" = lib.mkIf cfg.isabelroses-web.enable {
        image = "docker.io/isabelroses/isabelroses.com:latest";
        ports = ["3000:3000"];
        extraOptions = ["-l=io.containers.autoupdate=registry" "--pull=newer"];
        environmentFiles = [
          config.sops.secrets.isabelroses-web-env.path
        ];
      };
    };
  };
}
