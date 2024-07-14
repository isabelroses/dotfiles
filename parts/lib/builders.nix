{
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs) self;

  inherit (lib.lists) singleton concatLists;
  inherit (lib.modules) mkMerge mkDefault;
  inherit (import ./hardware.nix { inherit lib; }) ldTernary;

  # mkSystem is a helper function that wraps lib.nixosSystem
  mkSystem = lib.nixosSystem;

  # mkNixSystem is a function that uses withSystem to give us inputs' and self'
  # it also assumes the the system type either nixos or darwin and uses the appropriate
  mkNixSystem =
    {
      host,
      deployable ? false,
      modules,
      system,
      ...
    }@args:
    withSystem system (
      { inputs', self', ... }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};

        # yet another helper function that wraps lib.nixosSystem
        # or lib.darwinSystem based on the system type
        mkSystem' = ldTernary pkgs mkSystem inputs.darwin.lib.darwinSystem;

        # this is used to determine the target system and modules that are going to be needed
        # for this specific system
        target = ldTernary pkgs "nixos" "darwin";
      in
      lib.mkMerge [
        {
          "${target}Configurations".${args.host} = mkSystem' {
            specialArgs = {
              inherit
                lib
                inputs
                self
                inputs'
                self'
                ;
            } // (args.specialArgs or { });

            modules = concatLists [
              [
                # depending on the base operating system we can only use some options therefore these
                # options means that we can limit these options to only those given operating systems
                "${self}/modules/${target}"

                # import home-manager for our target system
                inputs.home-manager."${target}Modules".home-manager

                # configurations based on that are imported based hostname
                "${self}/hosts/${args.host}"
              ]

              (singleton {
                config = {
                  garden.system.hostname = args.host;
                  nixpkgs.hostPlatform = mkDefault args.system;
                };
              })

              (args.modules or [ ])
            ];
          };
        }

        # deploy-rs allows us to deploy to a remote system
        # this is will enabled hosts if they are deployable
        (lib.mkIf deployable {
          deploy = {
            autoRollback = mkDefault true;
            magicRollback = mkDefault true;

            nodes.${args.host} = {
              hostname = args.host;
              skipChecks = true;
              sshUser = "isabel";
              user = "root";
              profiles.system.path =
                inputs.deploy-rs.lib.${system}.activate.nixos
                  inputs.self.nixosConfigurations.${args.host};
            };
          };
        })
      ]
    );

  # mkNixosIso is a helper function that wraps mkSystem to create an iso
  # DO NOT use mkNixSystem here as it is overkill for isos, furthermore we cannot use darwinSystem here
  mkNixosIso =
    {
      host,
      system,
      modules,
      ...
    }@args:
    {
      nixosConfigurations.${args.host} = mkSystem {
        specialArgs = {
          inherit inputs lib self;
        } // (args.specialArgs or { });

        modules = concatLists [
          # get an installer profile from nixpkgs to base the Isos off of
          [ "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix" ]

          # import our custom modules for the iso
          [ "${self}/modules/iso" ]

          # set the hostname for the iso
          (singleton {
            networking.hostName = args.host;
            nixpkgs.hostPlatform = mkDefault args.system;
          })

          # load any extra arguments the user has supplied
          (args.modules or [ ])
        ];
      };

      images.${args.host} = self.nixosConfigurations.${args.host}.config.system.build.isoImage;
    };

  # mkSystems is a wrapper for mkNixSystem to create a list of systems
  mkSystems = systems: mkMerge (map mkNixSystem systems);

  # mkNixosIsos likewise to mkSystems is a wrapper for mkNixosIso to create a list of isos
  mkNixosIsos = isos: mkMerge (map mkNixosIso isos);
in
{
  inherit mkSystems mkNixosIsos;
}
