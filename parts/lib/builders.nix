{
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs) self;

  inherit (lib) nixosSystem;
  inherit (lib.lists) singleton concatLists;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.modules) mkMerge mkDefault;
  inherit (lib.hardware) ldTernary;
  inherit (inputs.darwin.lib) darwinSystem;

  # mkSystem is a function that uses withSystem to give us inputs' and self'
  # it also assumes the the system type either nixos or darwin and uses the appropriate
  mkSystem =
    {
      host,
      modules,
      system,
      ...
    }@args:
    withSystem system (
      { self', inputs', ... }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};

        # yet another helper function that wraps lib.nixosSystem
        # or lib.darwinSystem based on the system type
        mkSystem' = ldTernary pkgs nixosSystem darwinSystem;

        # this is used to determine the target system and modules that are going to be needed
        # for this specific system
        target = ldTernary pkgs "nixos" "darwin";
      in
      mkSystem' {
        # we use recursiveUpdate such that users can "override" the specialArgs
        specialArgs = recursiveUpdate {
          inherit
            lib
            self
            self'
            inputs
            inputs'
            ;
        } (args.specialArgs or { });

        modules = concatLists [
          # depending on the base operating system we can only use some options therefore these
          # options means that we can limit these options to only those given operating systems
          [ "${self}/modules/${target}" ]

          # configurations based on that are imported based hostname
          [ "${self}/systems/${args.host}" ]

          (singleton {
            config = {
              garden.system.hostname = args.host;
              nixpkgs.hostPlatform = mkDefault args.system;
            };
          })

          (args.modules or [ ])
        ];
      }
    );

  # mkIso is a helper function that wraps mkSystem to create an iso
  # DO NOT use mkSystem here as it is overkill for isos, furthermore we cannot use darwinSystem here
  mkIso =
    {
      host,
      system,
      modules,
      ...
    }@args:
    nixosSystem {
      specialArgs = recursiveUpdate { inherit lib self inputs; } (args.specialArgs or { });

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

  # mkSystems is a wrapper for mkNixSystem to create a list of systems
  mkSystems = systems: mkMerge (map (system: { ${system.host} = mkSystem system; }) systems);

  # mkIsos likewise to mkSystems is a wrapper for mkIso to create a list of isos
  mkIsos = isos: mkMerge (map (iso: { ${iso.host} = mkIso iso; }) isos);
in
{
  inherit
    mkIso
    mkIsos
    mkSystem
    mkSystems
    ;
}
