{
  lib,
  pkgs,
  ...
}:
with lib; {
  options.modules.system = {
    # the default user (not users) you plan to use on a specific device
    # this will dictate the initial home-manager settings if home-manager is
    # enabled in usrenv
    username = mkOption {
      type = types.str;
      description = "The username of the non-root superuser for your system";
    };

    hostname = mkOption {
      type = types.str;
      description = "The name of the device for the system";
    };

    # the path to the flake
    flakePath = mkOption {
      type = types.str;
      default = "/home/isabel/.setup";
      description = "The path to the configuration";
    };

    # should sound related programs and audio-dependent programs be enabled
    sound = {
      enable = mkEnableOption "sound";
    };

    # should the device enable graphical programs
    video = {
      enable = mkEnableOption "video";
    };

    # should the device load bluetooth drivers and enable blueman
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };

    # should the device enable printing module and try to load common printer modules
    # you might need to add more drivers to the printing module for your printer to work
    printing = {
      enable = mkEnableOption "printing";
    };

    # pre-boot and bootloader configurations
    boot = {
      enableKernelTweaks = mkEnableOption "security and performance related kernel parameters";
      enableInitrdTweaks = mkEnableOption "quality of life tweaks for the initrd stage";
      recommendedLoaderConfig = mkEnableOption "tweaks for common bootloader configs per my liking";
      loadRecommendedModules = mkEnableOption "kernel modules that accommodate for most use cases";

      extraKernelParams = mkOption {
        type = with types; listOf string;
        default = [];
      };

      kernel = mkOption {
        type = types.raw;
        default = pkgs.linuxPackages_latest;
      };

      # the bootloader that should be used
      loader = mkOption {
        type = types.enum ["none" "grub" "systemd-boot"];
        default = "none";
        description = "The bootloader that should be used for the device.";
      };

      plymouth = {
        enable = mkEnableOption "plymouth boot splash";
        withThemes = mkEnableOption "plymouth theme";
      };
    };

    # should virtualization (docker, qemu, podman etc.) be enabled
    virtualization = {
      enable = mkEnableOption "virtualization";
      docker = {enable = mkEnableOption "docker";};
      podman = {enable = mkEnableOption "podman";};
      qemu = {enable = mkEnableOption "qemu";};
      distrobox = {enable = mkEnableOption "distrobox";};
      waydroid = {enable = mkEnableOption "waydroid";};
    };

    # should we optimize tcp networking
    networking = {
      optimizeTcp = mkOption {
        type = types.bool;
        default = false;
        description = "Enable tcp optimizations";
      };
    };

    security = {
      fixWebcam = mkEnableOption "Fix the purposefully broken webcam by un-blacklisting the related kernel module.";

      secureBoot = mkEnableOption "Enable secure-boot and load necessary packages.";
    };
  };
}
