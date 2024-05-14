{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.modules.system.encryption;
in
{
  config = mkIf cfg.enable {
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
