{ lib, pkgs, ... }:
let
  inherit (lib.modules) mkForce mkAfter mkImageMediaOverride;
in
{
  boot = {
    # this can help with driver issues mainly
    # nvidia will forever be the bane of my existence
    kernelPackages = mkImageMediaOverride pkgs.linuxPackages_latest;

    kernelParams = mkAfter [
      "noquiet"
      "toram"
    ];

    # we have no need for systemd in initrd installation media
    initrd.systemd = {
      enable = mkImageMediaOverride false;
      emergencyAccess = mkImageMediaOverride true;
    };

    # have no need for systemd-boot
    loader.systemd-boot.enable = mkForce false;
    # we don't need to have any raid tools in our system
    swraid.enable = mkForce false;

    # https://github.com/NixOS/nixpkgs/issues/58959
    supportedFilesystems = mkForce [
      "btrfs"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "cifs"
    ];
  };
}
