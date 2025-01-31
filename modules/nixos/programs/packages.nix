{ pkgs, ... }:
{
  # packages that should be on all deviecs
  garden.packages = {
    inherit (pkgs)
      git
      curl
      wget
      pciutils
      lshw
      ;
  };
}
