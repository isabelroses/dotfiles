{ lib, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/eca4605163a534aed1981de0f5f1d7d7639d1640/nixos/modules/programs/environment.nix#L18
  environment.variables.NIXPKGS_CONFIG = lib.mkForce "";
}
