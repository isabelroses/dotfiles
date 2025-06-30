{ lib, pkgs, ... }:
{
  garden.packages = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
    quickshell = pkgs.quickshell.overrideAttrs (oa: {
      buildInputs = oa.buildInputs or [ ] ++ [
        pkgs.kdePackages.qtimageformats
      ];
    });
  };
}
