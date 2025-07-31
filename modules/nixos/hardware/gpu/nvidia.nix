{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (config.garden) device;
  inherit (lib) mkIf mkDefault;
in
{
  config = mkIf (device.gpu == "nvidia") {
    services.xserver.videoDrivers = [ "nvidia" ];

    # Enables the Nvidia's experimental framebuffer device
    # fix for the imaginary monitor that does not exist
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";

      # GBM_BACKEND = "nvidia-drm"; # breaks firefox apparently
      WLR_DRM_DEVICES = mkDefault "/dev/dri/card1";
    };

    garden.packages = {
      inherit (pkgs.nvtopPackages) nvidia;

      inherit (pkgs)
        # vulkan
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer

        # libva
        libva
        libva-utils
        ;
    };

    hardware = {
      nvidia = {
        # use the latest and greatest nvidia drivers
        package = config.boot.kernelPackages.nvidiaPackages.beta;

        powerManagement = {
          enable = true;
          finegrained = false;
        };

        # dont use the open drivers by default
        open = false;

        # adds nvidia-settings to pkgs, so useless on nixos
        nvidiaSettings = false;

        nvidiaPersistenced = true;
      };

      graphics = {
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
        extraPackages32 = [ pkgs.pkgsi686Linux.nvidia-vaapi-driver ];
      };
    };
  };
}
