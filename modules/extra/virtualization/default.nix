{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  sys = config.modules.system.virtualization;
in {
  config = mkIf (sys.enable) {
    environment.systemPackages = with pkgs;
      []
      ++ optionals (sys.qemu.enable) [
        virt-manager
        virt-viewer
      ]
      ++ optionals (sys.docker.enable) [
        docker
        docker-compose
      ]
      ++ optionals (sys.distrobox.enable) [
        distrobox
      ];

    virtualisation = mkIf (sys.enable) {
      
      docker = mkIf (sys.docker.enable) {
        enable = true;

        enableNvidia = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;

        autoPrune = {
          enable = true;
          flags = ["--all"];
          dates = "weekly";
        };
      };

    };
  };
}
