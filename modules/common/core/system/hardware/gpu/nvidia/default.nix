{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # use the latest possible nvidia package
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;

  nvidiaPackage =
    if (versionOlder nvBeta nvStable)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;

  inherit (config.modules) device;
  env = config.modules.usrEnv;
in {
  config = mkIf (device.gpu == "nvidia" || device.gpu == "hybrid-nv") {
    # nvidia drivers are unfree software
    nixpkgs.config.allowUnfree = true;

    services.xserver = mkMerge [
      {
        videoDrivers = ["nvidia"];
      }

      # xorg settings
      (mkIf (!env.isWayland) {
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
      # blacklist nouveau module so that it does not conflict with nvidia drm stuff
      # also the nouveau performance is godawful, I'd rather run linux on a piece of paper than use nouveau
      blacklistedKernelModules = ["nouveau"];
    };

    environment = {
      sessionVariables = mkMerge [
        {
          LIBVA_DRIVER_NAME = "nvidia";
        }

        (mkIf env.isWayland {
          WLR_NO_HARDWARE_CURSORS = "1";
          #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
          #GBM_BACKEND = "nvidia-drm"; # breaks firefox apparently
        })

        (mkIf (env.isWayland && device.gpu == "hybrid-nv") {
          #__NV_PRIME_RENDER_OFFLOAD = "1";
          #WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
        })
      ];
      systemPackages = with pkgs; [
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        libva
        libva-utils
      ];
    };

    hardware = {
      nvidia = {
        package = mkDefault nvidiaPackage;
        modesetting.enable = mkDefault true;
        prime.offload.enableOffloadCmd = device.gpu == "hybrid-nv";
        powerManagement = {
          enable = mkDefault true;
          finegrained = mkDefault true;
        };

        # use open source drivers by default, hosts may override this option if their gpu is
        # not supported by the open source drivers
        open = mkDefault true;
        nvidiaSettings = false; # add nvidia-settings to pkgs, useless on nixos
        nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
      };

      opengl = {
        extraPackages = with pkgs; [nvidia-vaapi-driver];
        extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver];
      };
    };
  };
}
