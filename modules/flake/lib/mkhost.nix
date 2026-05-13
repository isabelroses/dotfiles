{
  lib,
  inputs,
}:
let
  inherit (inputs) self;

  inherit (lib.attrsets) mapAttrs;
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
    }
  ```
*/
name:
{
  arch ? "x86_64",
  class ? "nixos",
}:
let
  inherit (inputs) darwin nixpkgs;

  os =
    {
      iso = "linux";
      nixos = "linux";
    }
    .${class} or class;
  system = "${arch}-${os}";

  evalHost = if class == "darwin" then darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

  # since i'm not using flake.parts at this current time but i still want the
  # power that comes with using flake.parts i effectively recreate `inputs'`
  # here. i wrote about this in my blog post:
  # <https://isabelroses.com/blog/custom-lib-nixossystem/#the-final-touch>
  inputs' = mapAttrs (_: mapAttrs (_: v: v.${system} or v)) inputs;
in
evalHost {
  # `specialArgs` should only be used for arguments that need to be evaluated
  # when resolving module structure (like in imports). for everything else we
  # have `_module.args`
  specialArgs = {
    inherit inputs self;
  };

  modules = [
    # import our host system paths
    "${self}/systems/${name}/default.nix"

    # import the files required for the class
    "${self}/modules/${class}/default.nix"

    # recall `specialArgs` would take be preferred when resolving module structure
    # well this is how we do it use it for all args that don't need to rosolve module structure
    {
      key = "dotfiles#specialArgs";
      _file = "${__curPos.file}";

      _module.args = {
        inherit inputs';
        self' = inputs'.self;
      };
    }

    # here we make some basic assumptions about the system the person is using
    # like the system type and the hostname
    {
      key = "dotfiles#hostname";
      _file = "${__curPos.file}";

      # we set the systems hostname based on the host value
      # which should be a string that is the hostname of the system
      networking.hostName = name;
    }

    {
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
    }
  ]
  # if we are on darwin we need to import the nixpkgs source, its used in some
  # modules, if this is not set then you will get an error
  ++ lib.optional (class == "darwin") {
    key = "dotfiles#nixpkgs-darwin";
    _file = "${__curPos.file}";

    # without supplying an upstream nixpkgs source, nix-darwin will not be able to build
    # and will complain and log an error demanding that you must set this value
    nixpkgs.source = nixpkgs;
  };
}
