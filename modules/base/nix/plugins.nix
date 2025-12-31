{ pkgs, ... }:
{
  garden.packages = {
    inherit (pkgs) lix-diff;
  };
}
