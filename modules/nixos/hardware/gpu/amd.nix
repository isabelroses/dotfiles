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
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd") {
    # enable amdgpu xorg drivers
    services.xserver.videoDrivers = [ "amdgpu" ];

    # enable amdgpu kernel module
    boot = {
      kernelModules = [ "amdgpu" ];
      initrd.kernelModules = [ "amdgpu" ];
    };

    # enables AMDVLK & OpenCL support
    hardware.graphics.extraPackages = with pkgs; [
      # opencl drivers
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
}
