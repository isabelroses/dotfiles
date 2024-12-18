{
  lib,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs) self;

  inherit (builtins)
    filter
    pathExists
    ;
  inherit (lib.lists) optionals singleton flatten;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.modules) mkDefault evalModules;

  /**
    mkSystem is a function that uses withSystem to give us inputs' and self'
    it also assumes the the system type either nixos or darwin and uses the appropriate

    # Type

    ```
    mkSystem :: AttrSet -> AttrSet
    ```

    # Example

    ```nix
      mkSystem {
        name = "myhost";
        system = "x86_64-linux";
        target = "nixos";
        modules = [ ./module.nix ];
        specialArgs = { foo = "bar"; };
      }
    ```
  */
  mkSystem =
    {
      name,
      target ? "nixos",
      system ? "x86_64-linux",
      modules ? [ ],
      specialArgs ? { },
    }:
    withSystem system (
      { self', inputs', ... }:
      let
        eval = evalModules {
          # we use recursiveUpdate such that users can "override" the specialArgs
          #
          # This should only be used for special arguments that need to be evaluated
          # when resolving module structure (like in imports).
          specialArgs = recursiveUpdate {
            # create the modulesPath based on the system, we need
            modulesPath =
              if target == "darwin" then "${inputs.darwin}/modules" else "${inputs.nixpkgs}/nixos/modules";

            # laying it out this way is completely arbitrary, however it looks nice i guess
            inherit lib;
            inherit self self';
            inherit inputs inputs';
          } specialArgs;

          # A nominal type for modules. When set and non-null, this adds a check to
          # make sure that only compatible modules are imported.
          class = target;

          modules = flatten [
            (filter pathExists [
              # depending on the base operating system we can only use some options therefore these
              # options means that we can limit these options to only those given operating systems
              "${self}/modules/${target}/default.nix"

              # configurations based on that are imported based hostname,
              # these don't exist for iso systems (at the moment) so we ignore those
              "${self}/systems/${name}/default.nix"
            ])

            # we can't import these for isos since they are supposed to be minimal
            # and would bloat the iso massively if we did import them
            (optionals (target != "iso") [
              # import the home module, which is users for configuring users via home-manager
              "${self}/home/default.nix"

              # import the base module, this contains the common configurations between all systems
              "${self}/modules/base/default.nix"
            ])

            # get an installer profile from nixpkgs to base the Isos off of
            # this is useful because it makes things alot easier
            (optionals (target == "iso") [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"
            ])

            # we need to import the module list for our system
            # this is either the nixos modules list provided by nixpkgs
            # or the darwin modules list provided by nix darwin
            (import (
              if target == "darwin" then
                "${inputs.darwin}/modules/module-list.nix"
              else
                "${inputs.nixpkgs}/nixos/modules/module-list.nix"
            ))

            (singleton {
              # TODO: learn what this means and why its needed to build the iso
              _module.args.modules = [ ];

              # we set the systems hostname based on the host value
              # which should be a string that is the hostname of the system
              networking.hostName = name;

              nixpkgs = {
                # you can also do this as `inherit system;` with the normal `lib.nixosSystem`
                # however for evalModules this will not work, so we do this instead
                hostPlatform = mkDefault system;

                # The path to the nixpkgs sources used to build the system.
                # This is automatically set up to be the store path of the nixpkgs flake used to build
                # the system if using lib.nixosSystem, and is otherwise null by default.
                # so that means that we should set it to our nixpkgs flake output path
                flake.source = inputs.nixpkgs.outPath;
              };
            })

            # if we are on darwin we need to import the nixpkgs source, its used in some
            # modules, if this is not set then you will get an error
            (optionals (target == "darwin") (singleton {
              # without supplying an upstream nixpkgs source, nix-darwin will not be able to build
              # and will complain and log an error demanding that you must set this value
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

            # import any additional modules that the user has provided
            modules
          ];
        };
      in
      if (target == "nixos" || target == "iso") then
        { nixosConfigurations.${name} = eval; }
      else
        {
          darwinConfigurations.${name} = eval // {
            system = eval.config.system.build.toplevel;
          };
        }
    );
in
{
  inherit mkSystem;
}
