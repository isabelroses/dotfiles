{
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;

  inherit (import ./hardware.nix {inherit lib;}) ldTernary;

  # mkSystem is a helper function that wraps lib.nixosSystem
  mkSystem = lib.nixosSystem;

  # mkNixSystem is a function that uses withSystem to give us inputs' and self'
  # it also assumes the the system type either nixos or darwin and uses the appropriate
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

      # yet another helper function that wraps lib.nixosSystem
      # or lib.darwinSystem based on the system type
      mkSystem' = ldTernary pkgs mkSystem inputs.darwin.lib.darwinSystem;

      # this is used to determin the target system and modules that are going to be needed
      # for this specific system
      target = ldTernary pkgs "nixos" "darwin";
    in {
      "${target}Configurations".${args.host} = mkSystem' {
        inherit system;
        modules =
          [
            # depending on the base operating system we can only use some options therfore these
            # options means that we can limit these options to only those given operating systems
            "${self}/modules/${target}"
            inputs.home-manager."${target}Modules".home-manager

            # configrations based on that are imported based hostname
            "${self}/hosts/${args.host}"
            {config.modules.system.hostname = args.host;}
          ]
          ++ args.modules or [];
        specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
      };
    });

  # mkNixosIso is a helper function that wraps mkSystem to create an iso
  # DO NOT use mkNixSystem here as it is overkill for isos, futhermore we cannot use darwinSystem here
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
        ]
        ++ args.modules or [];
    };
  };

  # mkSystems is a wrapper for mkNixSystem to create a list of systems
  mkSystems = systems: lib.mkMerge (map mkNixSystem systems);

  # mkNixosIsos likewise to mkSystems is a wrapper for mkNixosIso to create a list of isos
  mkNixosIsos = systems: lib.mkMerge (map mkNixosIso systems);
in {
  inherit mkSystems mkNixosIsos;
}
