{
  pkgs,
  lib,
  ...
}: {
  boot = {
    kernelParams = lib.mkAfter ["noquiet"];
    # we have no need for systemd in initrd installation media
    initrd.systemd = {
      enable = lib.mkImageMediaOverride false;
      emergencyAccess = lib.mkImageMediaOverride true;
    };
    kernelPackages = pkgs.linuxPackages_latest;

    # https://github.com/NixOS/nixpkgs/issues/58959
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
