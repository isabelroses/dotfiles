{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  # inherit self from inputs
  self = inputs.self;

  # just an alias to nixpkgs.lib.nixosSystem, lets me avoid adding
  # nixpkgs to the scope in the file it is used in
  mkSystem = nixpkgs.lib.nixosSystem;

  # mkNixosSystem wraps mkSystem (a.k.a lib.nixosSystem) with flake-parts' withSystem to provide inputs' and self' from flake-parts
  # it also acts as a template for my nixos hosts with system type and modules being imported beforehand
  # specialArgs is also defined here to avoid defining them for each host and lazily merged if the host defines any other args
  mkNixosSystem = {
    modules,
    system,
    withSystem,
    ...
  } @ args:
    withSystem system ({
      inputs',
      self',
      ...
    }:
      mkSystem {
        inherit modules system;
        specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
      });
in {
  inherit mkSystem mkNixosSystem;
}
