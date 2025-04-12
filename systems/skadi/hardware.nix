{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_scsi"
    ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/70f72b4d-9468-4779-aed8-2d4a5fa6737c";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/949B-0F76";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
    };

    services = {
      smartd.enable = mkForce false; # Unavailable - device lacks SMART capability.
      thermald.enable = mkForce false; # Unavailable - device lacks thermal sensors.

      qemuGuest.enable = true;
    };

    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];
  };
}
