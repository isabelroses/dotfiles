{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = lib.mkImageMediaOverride "lilith";

  isoImage = let
    rev = self.shortRev or "dirty";
  in {
    # lilith-$rev-$arch.iso
    isoName = lib.mkImageMediaOverride "lilith-${config.system.nixos.release}-${rev}-${pkgs.stdenv.hostPlatform.uname.processor}.iso";
    # lilith-$release-$rev-$arch
    volumeID = "lilith-${config.system.nixos.release}-${rev}-${pkgs.stdenv.hostPlatform.uname.processor}";

    # faster compression in exchange for larger iso size
    squashfsCompression = "gzip -Xcompression-level 1";
  };
}
