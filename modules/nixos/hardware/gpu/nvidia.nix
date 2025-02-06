{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (config.garden) device;
  inherit (lib.modules)
    mkIf
    mkMerge
    mkDefault
    ;
  inherit (self.lib.validators) isWayland;

  isHybrid = device.gpu == "hybrid-nv";
in
{
  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nv") {
    # nvidia drivers kinda are unfree software
    nixpkgs.config.allowUnfree = true;

    services.xserver = mkMerge [
      { videoDrivers = [ "nvidia" ]; }

      # xorg settings
      (mkIf (!isWayland config) {
        # disable DPMS
        monitorSection = ''
          Option "DPMS" "false"
        '';

        # disable screen blanking in general
        serverFlagsSection = ''
          Option "StandbyTime" "0"
          Option "SuspendTime" "0"
          Option "OffTime" "0"
          Option "BlankTime" "0"
        '';
      })
    ];

    boot = {
      # blacklist nouveau module as otherwise it conflicts with nvidia drm
      blacklistedKernelModules = [ "nouveau" ];

      # Enables the Nvidia's experimental framebuffer device
      # fix for the imaginary monitor that does not exist
      kernelParams = [ "nvidia_drm.fbdev=1" ];
    };

    environment.sessionVariables = mkMerge [
      { LIBVA_DRIVER_NAME = "nvidia"; }

      (mkIf (isWayland config) {
        # GBM_BACKEND = "nvidia-drm"; # breaks firefox apparently

        WLR_DRM_DEVICES = mkDefault "/dev/dri/card1";
      })
    ];

    garden.packages = {
      inherit (pkgs.nvtopPackages) nvidia;

      inherit (pkgs)
        # mesa
        mesa

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
        package = mkDefault config.boot.kernelPackages.nvidiaPackages.beta;

        prime.offload = {
          enable = isHybrid;
          enableOffloadCmd = isHybrid;
        };

        powerManagement = {
          enable = mkDefault true;
          finegrained = mkDefault false;
        };

        open = false; # dont use the open drivers by default
        nvidiaSettings = false; # adds nvidia-settings to pkgs, so useless on nixos
        nvidiaPersistenced = true;
        # forceFullCompositionPipeline = true;
      };

      graphics = {
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
        extraPackages32 = [ pkgs.pkgsi686Linux.nvidia-vaapi-driver ];
      };
    };
  };
}
