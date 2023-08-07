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
}
