{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.system = {
    # should virtualization (docker, qemu, podman etc.) be enabled
    virtualization = {
      enable = mkEnableOption "virtualization";
      docker = {enable = mkEnableOption "docker";};
      podman = {enable = mkEnableOption "podman";};
      qemu = {enable = mkEnableOption "qemu";};
      distrobox = {enable = mkEnableOption "distrobox";};
      waydroid = {enable = mkEnableOption "waydroid";};
    };
  };
}
