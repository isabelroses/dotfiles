{
  config,
  lib,
  pkgs,
  ...
}: let
  device = config.modules.device;
in {
  config = lib.mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd") {
    # enable amdgpu xorg drivers
    services.xserver.videoDrivers = ["amdgpu"];

    # enable amdgpu kernel module
    boot = {
      kernelModules = ["amdgpu"];
      initrd.kernelModules = ["amdgpu"];
    };

    # enables AMDVLK & OpenCL support
    hardware.opengl.extraPackages = with pkgs; [
      # opencl drivers
      rocm-opencl-icd
      rocm-opencl-runtime
    ];

    /*
    hardware.opengl.extraPackages32 = with pkgs; [
    ];
    */
  };
}
