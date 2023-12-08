{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;

  # just an alias to nixpkgs.lib.nixosSystem
  mkSystem = lib.nixosSystem;

  # mkNixosSystem wraps mkSystem (or lib.nixosSystem) with flake-parts' withSystem to give us inputs' and self' from flake-parts
  # which can also be used as a template for nixos hosts with system type and modules to be imported with ease
  # specialArgs is also defined here to avoid defining them for each host
  mkNixosSystem = host: {
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
        inherit system;
        modules =
          [
            "${self}/hosts/${host}"
            {config.modules.system.hostname = host;}
          ]
          ++ args.modules or [];
        specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
      });

  # mkIso is should be a set that extends mkSystem (again) with necessary modules to create an Iso image
  # don't use mkNixosSystem as it is complelty overkill for an iso and will have too much data, we need a light weight image
  mkNixosIso = host: {system, ...} @ args:
    mkSystem {
      inherit system;
      specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
      modules =
        [
          # get an installer profile from nixpkgs to base the Isos off of
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          "${self}/hosts/${host}"
        ]
        ++ args.modules or [];
    };
in {
  inherit mkSystem mkNixosSystem mkNixosIso;
}
