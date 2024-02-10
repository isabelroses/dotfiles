{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;

  inherit (import ./hardware.nix {inherit lib;}) ldTernary;

  # mkSystem is a helper function that wraps lib.nixosSystem
  mkSystem = lib.nixosSystem;

  # mkNixSystem wraps mkSystem with flake-parts' withSystem to give us inputs' and self' from flake-parts
  # which can also be used as a template for nixos hosts with system type and modules to be imported with ease
  # specialArgs is also defined here to avoid defining them for each host
  mkNixSystem = {
    host,
    modules,
    system,
    withSystem,
    ...
  } @ args:
    withSystem system ({
      inputs',
      self',
      ...
    }: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      mkSystem' = ldTernary pkgs mkSystem inputs.darwin.lib.darwinSystem;
      # this is used to determin the target system and modules that are going to be needed
      # for this specific system
      target = ldTernary pkgs "nixosConfigurations" "darwinConfigurations";
      mod = ldTernary pkgs "nixosModules" "darwinModules";

      hm = inputs.home-manager.${mod}.home-manager;
    in {
      ${target}.${args.host} = mkSystem' {
        inherit system;
        modules =
          [
            hm
            "${self}/hosts/${args.host}"
            {config.modules.system.hostname = args.host;}
          ]
          ++ args.modules or [];
        specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
      };
    });

  # mkIso is should be a set that extends mkSystem (again) with necessary modules to create an Iso image
  # don't use mkNixSystem as it is complelty overkill for an iso and will have too much data, we need a light weight image
  mkNixosIso = {
    host,
    system,
    modules,
    ...
  } @ args: {
    nixosConfigurations.${args.host} = mkSystem {
      inherit system;
      specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
      modules =
        [
          # get an installer profile from nixpkgs to base the Isos off of
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          "${self}/hosts/${args.host}"

          {config.networking.hostName = args.host;}
        ]
        ++ args.modules or [];
    };
  };

  mkSystems = systems: lib.mkMerge (map mkNixSystem systems);

  mkNixosIsos = systems: lib.mkMerge (map mkNixosIso systems);
in {
  inherit mkSystems mkNixosIsos;
}
