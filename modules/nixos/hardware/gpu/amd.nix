{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (config.garden) device;
in
{
  config = mkIf (device.gpu == "amd") {
    # enable amdgpu xorg drivers
    services.xserver.videoDrivers = [ "amdgpu" ];

    # enable amdgpu kernel module
    boot.kernelModules = [ "amdgpu" ];

    # enables AMDVLK & OpenCL support
    hardware.graphics.extraPackages = [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.clr.icd
    ];
  };
}
