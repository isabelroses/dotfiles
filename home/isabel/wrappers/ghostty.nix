{ pkgs, ... }:
{
  wrappers.ghostty = {
    basePackage = pkgs.ghostty;
  };
}
