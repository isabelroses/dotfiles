{ pkgs, ... }:
{
  # packages that should be on all deviecs
  garden.packages = {
    inherit (pkgs)
      curl
      wget
      pciutils
      lshw
      ;
  };
}
