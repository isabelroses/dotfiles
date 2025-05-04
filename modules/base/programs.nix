{ pkgs, ... }:
{
  garden.packages = {
    # GNU core utilities (rewritten in rust)
    # a good idea for usage on macOS too
    inherit (pkgs) uutils-coreutils-noprefix;
  };
}
