{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ec63ffc1-ebb8-404d-bc2f-1ce798991fce";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/382e3e9c-fd48-4ca4-adb6-ab558bfd5c35";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6BE3-A9DB";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/963c1c32-b43f-4dfb-a378-b82dc447ae4a";}
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
