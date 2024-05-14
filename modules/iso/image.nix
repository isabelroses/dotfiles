{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkImageMediaOverride;
in
{
  # We don't want to alter the iso image itself so we prevent rebuilds
  system.switch.enable = false;

  isoImage =
    let
      # Get the hostname from our networking name provided in the mkNixosIso builder
      # If none is set then default to "nixos"
      hostname = config.networking.hostName or "nixos";

      # We get the rev of the git tree here and if we don't have one that
      # must mean we have made local changes so we call the git tree "dirty"
      rev = self.shortRev or "dirty";

      # Give all the isos a consistent name
      # $hostname-$release-$rev-$arch
      name = "${hostname}-${config.system.nixos.release}-${rev}-${pkgs.stdenv.hostPlatform.uname.processor}";
    in
    {
      # From the name defined before we end up with: name.iso
      isoName = mkImageMediaOverride "${name}.iso";

      # volumeID is used is used by stage 1 of the boot process, so it must be distintctive
      volumeID = mkImageMediaOverride "${name}";

      # maximum compression, in exchange for build speed
      squashfsCompression = "zstd -Xcompression-level 10";

      # ISO image should be an EFI-bootable volume
      makeEfiBootable = true;

      # ISO image should be bootable from USB
      makeUsbBootable = true;

      # This should help for debugging if we ever get an unbootable system and have to
      # prefrom some repairs on the system itself
      contents = [
        {
          source = pkgs.memtest86plus + "/memtest.bin";
          target = "boot/memtest.bin";
        }
      ];
    };
}
