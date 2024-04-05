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
    deployable ? false,
    modules,
    system,
    withSystem,
    ...
  } @ args:
    withSystem system (
      {
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
      in
        lib.mkMerge [
          {
            "${target}Configurations".${args.host} = mkSystem' {
              inherit (args) system;
              modules =
                [
                  # depending on the base operating system we can only use some options therfore these
                  # options means that we can limit these options to only those given operating systems
                  "${self}/modules/${target}"
                  inputs.home-manager."${target}Modules".home-manager

                  # configrations based on that are imported based hostname
                  "${self}/hosts/${args.host}"
                  {
                    config = {
                      modules.system.hostname = args.host;
                      nixpkgs.hostPlatform = lib.mkDefault args.system;
                    };
                  }
                ]
                ++ args.modules or [];
              specialArgs = {inherit lib inputs self inputs' self';} // args.specialArgs or {};
            };
          }

          # deploy-rs allows us to deploy to a remote system
          # this is will enabled hosts if they are deployable
          (lib.mkIf deployable {
            deploy = {
              autoRollback = true;
              magicRollback = true;

              nodes.${args.host} = {
                hostname = args.host;
                skipChecks = true;
                sshUser = "root";
                user = "root";
                profiles.system.path = inputs.deploy-rs.lib.${system}.activate.nixos inputs.self.nixosConfigurations.${args.host};
              };
            };
          })
        ]
    );

  # mkNixosIso is a helper function that wraps mkSystem to create an iso
  # DO NOT use mkNixSystem here as it is overkill for isos, futhermore we cannot use darwinSystem here
  mkNixosIso = {
    host,
    system,
    modules,
    ...
  } @ args: {
    nixosConfigurations.${args.host} = mkSystem {
      inherit (args) system;
      specialArgs = {inherit inputs lib self;} // args.specialArgs or {};
      modules =
        [
          # get an installer profile from nixpkgs to base the Isos off of
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

          "${self}/modules/iso"
          {config.networking.hostName = args.host;}
        ]
        ++ args.modules or [];
    };

    images.${args.host} = self.nixosConfigurations.${args.host}.config.system.build.isoImage;
  };

  # mkSystems is a wrapper for mkNixSystem to create a list of systems
  mkSystems = systems: lib.mkMerge (map mkNixSystem systems);

  # mkNixosIsos likewise to mkSystems is a wrapper for mkNixosIso to create a list of isos
  mkNixosIsos = isos: lib.mkMerge (map mkNixosIso isos);
in {
  inherit mkSystems mkNixosIsos;
}
