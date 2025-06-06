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
        device = "/dev/disk/by-uuid/3ac0d35f-0807-4553-a17e-24b227f1a3b1";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/ED86-8CB2";
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
