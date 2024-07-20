{ self, ... }:
{
  flake.overlays.default = _: prev: { inherit (self.packages.${prev.stdenv.system}) lix; };
}
