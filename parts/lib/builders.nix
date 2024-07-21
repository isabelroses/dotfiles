{
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs) self;

  inherit (lib.lists) optionals singleton concatLists;
  inherit (lib.attrsets) recursiveUpdate optionalAttrs;
  inherit (lib.modules) mkMerge mkDefault evalModules;
  inherit (lib.hardware) ldTernary;

  # mkSystem is a function that uses withSystem to give us inputs' and self'
  # it also assumes the the system type either nixos or darwin and uses the appropriate
  mkSystem =
    {
      host,
      system,
      modules,
      ...
    }@args:
    withSystem system (
      { self', inputs', ... }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};

        # this is used to determine the target system and modules that are going to be needed
        # for this specific system
        target = ldTernary pkgs "nixos" "darwin";

        eval = evalModules {
          # we use recursiveUpdate such that users can "override" the specialArgs
          specialArgs = recursiveUpdate {
            # create the modulesPath based on the system, we need
            modulesPath = ldTernary pkgs "${inputs.nixpkgs}/nixos/modules" "${inputs.darwin}/modules";

            # laying it out this way is completely arbitrary, however it looks nice i guess
            inherit lib;
            inherit self self';
            inherit inputs inputs';
          } (args.specialArgs or { });

          # A nominal type for modules. When set and non-null, this adds a check to
          # make sure that only compatible modules are imported.
          class = target;

          modules = concatLists [
            # depending on the base operating system we can only use some options therefore these
            # options means that we can limit these options to only those given operating systems
            [ "${self}/modules/${target}" ]

            # configurations based on that are imported based hostname
            [ "${self}/systems/${args.host}" ]

            # we need to import the module list for our system
            # this is either the nixos modules list provided by nixpkgs
            # or the darwin modules list provided by nix darwin
            (import (
              ldTernary pkgs "${inputs.nixpkgs}/nixos/modules/module-list.nix"
                "${inputs.darwin}/modules/module-list.nix"
            ))

            (singleton {
              networking.hostName = args.host;
              # you can also do this as system = args.system; however for evalModules
              # this will not work, so we do this instead
              nixpkgs.hostPlatform = mkDefault args.system;
            })

            # if we are on darwin we need to import the nixpkgs source, its used in some
            # modules, if this is not set then you will get an error
            (optionals pkgs.stdenv.isDarwin (singleton {
              nixpkgs.source = mkDefault inputs.nixpkgs;
              system = {
                # i don't quite know why this is set but upstream does it so i will too
                checks.verifyNixPath = false;
                # we use these values to keep track of what upstream revision we are on, this also
                # prevents us from recreating docs for the same configuration build if nothing has changed
                darwinVersionSuffix = ".${inputs.darwin.shortRev or inputs.darwin.dirtyShortRev or "dirty"}";
                darwinRevision = inputs.darwin.rev or inputs.darwin.dirtyRev or "dirty";
              };
            }))

            (args.modules or [ ])
          ];
        };
      in
      # we broke don't just call evalModules here because we need to be able to
      # append system to the final evaluated result since nix darwin uses this to switch
      # the configuration on and off
      eval // optionalAttrs pkgs.stdenv.isDarwin { system = eval.config.system.build.toplevel; }
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
    lib.nixosSystem {
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
