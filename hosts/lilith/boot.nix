{
  pkgs,
  lib,
  ...
}: {
  boot = {
    kernelParams = lib.mkAfter ["noquiet"];
    # no need for systemd in the initrd stage on an installation media
    initrd.systemd = {
      enable = lib.mkImageMediaOverride false;
      emergencyAccess = lib.mkImageMediaOverride true;
    };
    # use the latest Linux kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Needed for https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "cifs"
    ];
  };
}
