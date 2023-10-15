{
  config,
  lib,
  ...
}: let
  cfg = config.modules.services.isabelroses-web;
in {
  virtualisation.oci-containers.containers.isabelroses-com = lib.mkIf cfg.enable {
    image = "docker.io/isabelroses/isabelroses.com:latest";
    ports = ["3000:3000"];
    extraOptions = ["-l=io.containers.autoupdate=registry" "--pull=newer"];
    environmentFiles = [
      config.sops.secrets.isabelroses-web-env.path
    ];
  };
}
