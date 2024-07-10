{ inputs, withSystem, ... }:
{
  flake.lib = import ./import.nix { inherit inputs withSystem; };
}
