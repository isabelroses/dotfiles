{
  config,
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

    memtest = {
      enable = mkEnableOption "memtest86+";
      package = mkOption {
        type = types.package;
        default = pkgs.memtest86plus;
        description = "The memtest package to use.";
      };
    };

    encryption = {
      enable = mkEnableOption "LUKS encryption";

      device = mkOption {
        type = types.str;
        default = "enc";
        description = ''
          The LUKS label for the device that will be decrypted on boot.
          Currently does not support multiple devices at once.
        '';
      };

      keyFile = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          The path to the keyfile that will be used to decrypt the device.
          Needs to be an absolute path, and the file must exist. Set to `null`
          to disable.
        '';
      };

      keySize = mkOption {
        type = types.int;
        default = 4096;
        description = ''
          The size of the keyfile in bytes.
        '';
      };

      fallbackToPassword = mkOption {
        type = types.bool;
        default = !config.boot.initrd.systemd.enable;
        description = ''
          Whether or not to fallback to password authentication if the keyfile
          is not present.
        '';
      };
    };

    plymouth = {
      enable = mkEnableOption "plymouth boot splash";
      withThemes = mkEnableOption "plymouth theme";
    };
  };
}
