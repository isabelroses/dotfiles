{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.system = {
    virtualization = {
      enable = mkEnableOption "Should the device be allowed to virtualizle processes";
      docker = {enable = mkEnableOption "docker";};
      podman = {enable = mkEnableOption "podman";};
      qemu = {enable = mkEnableOption "qemu";};
      distrobox = {enable = mkEnableOption "distrobox";};
      waydroid = {enable = mkEnableOption "waydroid";};
    };
  };
}
