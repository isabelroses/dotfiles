{lib, ...}: {
  boot.initrd = {
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      "usb_storage"
    ];

    luks.devices."crypt" = {
      bypassWorkqueues = true;
      # keyFileSize = 4096;
      # keyFile = "/dev/disk/by-id/"
      preLVM = true;
    };
  };

  services.lvm.enable = lib.mkForce true;
}
