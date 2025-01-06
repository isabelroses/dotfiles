# this file creates an overlay based on the packgaes that out flake provides
{ self, ... }:
{
  # get a list of packages for the host system, and if none exist use an empty set
  flake.overlays.default = _: prev: self.packages.${prev.stdenv.hostPlatform.system} or { };
}
