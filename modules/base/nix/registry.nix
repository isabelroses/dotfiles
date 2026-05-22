{ lib, inputs, ... }:
let
  inherit (lib.attrsets) filterAttrs attrValues mapAttrs;
  inherit (lib.modules) mkForce;
  inherit (lib.types) isType;

  flakeInputs = filterAttrs (name: value: (isType "flake" value) && (name != "self")) inputs;
in
{
  # The path to the nixpkgs sources used to build the system. This is
  # automatically set up to be the store path of the nixpkgs flake used to
  # build the system if using lib.nixosSystem, and is otherwise null by
  # default.
  #
  # now i actually set this back to null, because i want to do what this pr
  # does basically. nowhere is this option really used outside of the one
  # module so i can pretty much just null it and be fine
  # https://github.com/NixOS/nixpkgs/pull/388090
  nixpkgs.flake.source = mkForce null;

  # now the explanation is done above we can pin our nixpkgs and inputs
  # however we like
  nix = {
    # pin to avoid downloading and evaluating a new inputs everytime
    registry = mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = attrValues (mapAttrs (k: v: "${k}=flake:${v.outPath}") flakeInputs);
  };
}
