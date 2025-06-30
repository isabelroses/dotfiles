{ pkgs, ... }:
{
  garden.packages = {
    quickshell = pkgs.quickshell.overrideAttrs (oa: {
      buildInputs = oa.buildInputs or [ ] ++ [
        pkgs.kdePackages.qtimageformats
      ];
    });
  };
}
