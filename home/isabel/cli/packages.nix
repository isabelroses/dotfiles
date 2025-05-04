{ pkgs, ... }:
{
  garden.packages = {
    inherit (pkgs) gitMinimal just;
  };
}
