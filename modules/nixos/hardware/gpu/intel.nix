{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf attrValues;
  inherit (config.garden) device;
in
{
  config = mkIf (device.gpu == "intel" || device.gpu == "hybrid-nv") {
    # we enable modesetting since this is recomeneded for intel gpus
    services.xserver.videoDrivers = [ "modesetting" ];

    # i have a "Broadwell" or later gpu so i only bother installing the media driver
    hardware.graphics = {
      extraPackages = attrValues {
        inherit (pkgs) intel-media-driver intel-compute-runtime vpl-gpu-rt;
      };

      extraPackages32 = attrValues {
        inherit (pkgs.pkgsi686Linux) intel-media-driver;
      };
    };

    # garden.packages = [ pkgs.intel-gpu-tools ];

    # environment.variables = mkIf (config.hardware.graphics.enable && device.gpu != "hybrid-nv") {
    #   LIBVA_DRIVER_NAME = "iHD"; # prefer the modern backend
    #   VDPAU_DRIVER = "va_gl";
    # };
  };
}
