{ inputs, ... }:
{
  flake.lib = import ./import.nix { inherit inputs; };
}
