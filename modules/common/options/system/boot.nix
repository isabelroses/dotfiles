{
  lib,
  pkgs,
  ...
}:
with lib; {
  options.modules.system.boot = {
    enableKernelTweaks = mkEnableOption "security and performance related kernel parameters";
    enableInitrdTweaks = mkEnableOption "quality of life tweaks for the initrd stage";
    recommendedLoaderConfig = mkEnableOption "tweaks for common bootloader configs per my liking";
    loadRecommendedModules = mkEnableOption "kernel modules that accommodate for most use cases";

    extraKernelParams = mkOption {
      type = with types; listOf str;
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

    device = mkOption {
      type = with types; nullOr str;
      default = "nodev";
      description = "The device to install the bootloader to.";
    };

    plymouth = {
      enable = mkEnableOption "plymouth boot splash";
      withThemes = mkEnableOption "plymouth theme";
    };

    memtest = {
      enable = mkEnableOption "memtest86+";
      package = mkOption {
        type = types.package;
        default = pkgs.memtest86plus;
        description = "The memtest package to use.";
      };
    };
  };
}
