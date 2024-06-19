{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.modules.system.encryption;
in
{
  options.modules.system.encryption = {
    enable = mkEnableOption "LUKS encryption";

    device = mkOption {
      type = types.str; # this should actually be a list
      default = "";
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

  config = mkIf cfg.enable {
    warnings =
      mkIf config.modules.system.encryption.device == "" [
        ''
          You have enabled LUKS encryption, but have not selected a device, you may not be able to decrypt your disk on boot.
        ''
      ];

    # mildly improves performance for the disk encryption
    boot = {
      # mildly improves performance for the disk encryption
      initrd.availableKernelModules = [
        "aesni_intel"
        "cryptd"
        "usb_storage"
      ];

      kernelParams = [
        # Disable password timeout
        "luks.options=timeout=0"
        "rd.luks.options=timeout=0"
        "rootflags=x-systemd.device-timeout=0"
      ];
    };

    services.lvm.enable = true;

    # TODO: account for multiple encrypted devices
    boot.initrd.luks.devices."${cfg.device}" = {
      # improve performance on ssds
      bypassWorkqueues = true;
      preLVM = true;

      # the device with the matching id will be searched for the key file
      keyFile = mkIf (cfg.keyFile != null) "${cfg.keyFile}";
      keyFileSize = cfg.keySize;

      # if keyfile is not there, fall back to cryptsetup password
      inherit (cfg) fallbackToPassword; # IMPLIED BY config.boot.initrd.systemd.enable
    };
  };
}
