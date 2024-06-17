{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkOption
    mkEnableOption
    types
    ;
in
{
  options.modules.system.boot = {
    enableKernelTweaks = mkEnableOption "security and performance related kernel parameters";
    recommendedLoaderConfig = mkEnableOption "tweaks for common bootloader configs per my liking";
    loadRecommendedModules = mkEnableOption "kernel modules that accommodate for most use cases";
    tmpOnTmpfs = mkEnableOption "`/tmp` living on tmpfs. false means it will be cleared manually on each reboot";

    kernel = mkOption {
      type = types.raw;
      default = pkgs.linuxPackages_latest;
      description = "The kernel to use for the system.";
    };

    initrd = {
      enableTweaks = mkEnableOption "quality of life tweaks for the initrd stage";
      optimizeCompressor = mkEnableOption ''
        initrd compression algorithm optimizations for size.
        Enabling this option will force initrd to use zstd (default) with
        level 19 and -T0 (STDIN). This will reduce thee initrd size greatly
        at the cost of compression speed.
        Not recommended for low-end hardware.
      '';
    };

    # https://nixos.wiki/wiki/Secure_Boot
    secureBoot = mkEnableOption ''
      secure-boot and load necessary packages, say good bye to systemd-boot
    '';

    extraModprobeConfig = mkOption {
      type = types.str;
      default = ''options hid_apple fnmode=1'';
      description = "Extra modprobe config that will be passed to system modprobe config.";
    };

    silentBoot =
      mkEnableOption ''
        almost entirely silent boot process through `quiet` kernel parameter
      ''
      // {
        default = config.modules.system.boot.plymouth.enable;
      };

    extraKernelParams = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    extraModulePackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExpression ''with config.boot.kernelPackages; [acpi_call]'';
      description = "Extra kernel modules to be loaded.";
    };

    loader = mkOption {
      type = types.enum [
        "none"
        "grub"
        "systemd-boot"
      ];
      default = "none";
      description = "The bootloader that should be used for the device.";
    };

    grub = {
      device = mkOption {
        type = with types; nullOr str;
        default = "nodev";
        description = "The device to install the bootloader to.";
      };
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
  };
}
