{
  lib,
  inputs,
  ...
}: let
  # inherit self from inputs
  inherit (inputs) self;

  # just an alias to nixpkgs.lib.nixosSystem, lets me avoid adding
  # nixpkgs to the scope in the file it is used in
  mkSystem = lib.nixosSystem;

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

  # mkIso is should be a set that extends mkSystem with necessary modules
  # to create an Iso image
  # we do not use mkNixosSystem because it overcomplicates things, an ISO does not require what we get in return for those complications
  mkNixosIso = {
    modules,
    system,
    ...
  } @ args:
    mkSystem {
      inherit system;
      specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
      modules =
        [
          # get an installer profile from nixpkgs to base the Isos off of
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
        ]
        ++ args.modules or [];
    };
in {
  inherit mkSystem mkNixosSystem mkNixosIso;
}
