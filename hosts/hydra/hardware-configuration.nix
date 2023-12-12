{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
      kernelModules = [];
    };

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2cdcddcf-db9e-472f-ab4f-14e7b644beea";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2524-71ED";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e45cd5a5-ec02-4933-9adb-5d968f270f54";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
