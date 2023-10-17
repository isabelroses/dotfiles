{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd") {
    # enable amdgpu xorg drivers in case Hyprland breaks again
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
