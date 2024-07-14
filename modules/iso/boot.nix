{ lib, ... }:
let
  inherit (lib.modules) mkForce mkAfter mkImageMediaOverride;
in
{
  boot = {
    kernelParams = mkAfter [
      "noquiet"
      "toram"
    ];

    # nixos doesn't currently support this NixOS/nixpkgs#291750
    # so we disable it, TODO: change this when it gets fixed
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
