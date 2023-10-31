{
  nixpkgs,
  inputs,
  ...
}: let
  inherit (nixpkgs) lib;
  inherit (lib) foldl recursiveUpdate;

  builders = import ./builders.nix {inherit lib inputs nixpkgs;};
  services = import ./services.nix {inherit lib;};
  validators = import ./validators.nix {inherit lib;};
  helpers = import ./helpers.nix {inherit lib;};
  hardware = import ./hardware.nix {inherit lib;};
  aliases = import ./aliases.nix {inherit lib;};

  # recursively merges two attribute sets
  mergeRecursively = lhs: rhs: recursiveUpdate lhs rhs;
in
  lib.extend (_: _: foldl mergeRecursively {} [builders services validators helpers hardware aliases])
