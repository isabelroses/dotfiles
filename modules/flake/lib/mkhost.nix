{
  lib,
  inputs,
}:
let
  inherit (inputs) self;

  inherit (lib)
    optionals
    singleton
    concatLists
    recursiveUpdate
    mapAttrs
    ;
in
/**
  mkHost is a function that uses withSystem to give us inputs' and self'
  it also assumes the the system type either nixos or darwin and uses the appropriate

  # Type

  ```
  mkHost :: String -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
    mkHost "myhost" {
      arch = "x86_64";
      class = "nixos";
      modules = [ ./module.nix ];
      specialArgs = { foo = "bar"; };
    }
  ```
*/
name:
{
  arch ? "x86_64",
  class ? "nixos",
  modules ? [ ],
  specialArgs ? { },
  ...
}:
let
  inherit (inputs) darwin nixpkgs;

  os =
    {
      iso = "linux";
      wsl = "linux";
      nixos = "linux";
    }
    .${class} or class;
  system = "${arch}-${os}";

  evalHost = if class == "darwin" then darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
in
evalHost {
  # we use recursiveUpdate such that users can "override" the specialArgs
  #
  # This should only be used for special arguments that need to be evaluated
  # when resolving module structure (like in imports).
  specialArgs = recursiveUpdate {
    inherit
      # these are normal args that people expect to be passed,
      # but we expect to be evaluated when resolving module structure
      inputs

      # even though self is just the same as `inputs.self`
      # we still pass this as some people will use this
      self
      ;
  } specialArgs;

  modules = concatLists [
    [
      # import our host system paths
      "${self}/systems/${name}/default.nix"

      # import the files required for the class
      "${self}/modules/${class}/default.nix"
    ]

    # the next 3 singleton's are split up to make it easier to understand as they do things different things

    # recall `specialArgs` would take be preferred when resolving module structure
    # well this is how we do it use it for all args that don't need to rosolve module structure
    (singleton (
      { config, ... }:
      let
        inputs' = mapAttrs (_: mapAttrs (_: v: v.${config.nixpkgs.hostPlatform.system} or v)) inputs;
      in
      {
        key = "dotfiles#specialArgs";
        _file = "${__curPos.file}";

        _module.args = {
          inherit inputs';
          self' = inputs'.self;
        };
      }
    ))

    # here we make some basic assumptions about the system the person is using
    # like the system type and the hostname
    (singleton {
      key = "dotfiles#hostname";
      _file = "${__curPos.file}";

      # we set the systems hostname based on the host value
      # which should be a string that is the hostname of the system
      networking.hostName = name;
    })

    (singleton {
      key = "dotfiles#nixpkgs";
      _file = "${__curPos.file}";

      nixpkgs = {
        # you can also do this as `inherit system;` with the normal `lib.nixosSystem`
        # however for evalModules this will not work, so we do this instead
        hostPlatform = system;

        # The path to the nixpkgs sources used to build the system.
        # This is automatically set up to be the store path of the nixpkgs flake used to build
        # the system if using lib.nixosSystem, and is otherwise null by default.
        # so that means that we should set it to our nixpkgs flake output path
        flake.source = nixpkgs.outPath;
      };
    })

    # if we are on darwin we need to import the nixpkgs source, its used in some
    # modules, if this is not set then you will get an error
    (optionals (class == "darwin") (singleton {
      key = "dotfiles#nixpkgs-darwin";
      _file = "${__curPos.file}";

      # without supplying an upstream nixpkgs source, nix-darwin will not be able to build
      # and will complain and log an error demanding that you must set this value
      nixpkgs.source = nixpkgs;
    }))

    # import any additional modules that the user has provided
    modules
  ];
}
