{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  builders = import ./builders.nix {inherit lib inputs nixpkgs;};
  services = import ./services.nix {inherit lib;};
  validators = import ./validators.nix {inherit lib;};
  helpers = import ./helpers.nix {inherit lib;};
in
  nixpkgs.lib.extend (_: _: builders // services // validators // helpers)
