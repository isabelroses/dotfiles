{
  lib,
  sources,
}:
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
  inherit (sources) darwin nixpkgs;

  os =
    {
      iso = "linux";
      nixos = "linux";
    }
    .${class} or class;
  system = "${arch}-${os}";

  evalHost =
    if class == "darwin" then
      import "${darwin}/eval-config.nix"
    else
      import "${nixpkgs}/nixos/lib/eval-config.nix";

  inherit (import ./default.nix { inherit system; }) inputs;
  inherit (inputs) self;
in
evalHost {
  # this is the default for nixosSystem but we are really adding it for nix-darwin
  lib = import "${nixpkgs}/lib";

  # `specialArgs` should only be used for arguments that need to be evaluated
  # when resolving module structure (like in imports). for everything else we
  # have `_module.args`
  specialArgs = {
    inherit self inputs;
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

      # you can also do this as `inherit system;` with the normal `lib.nixosSystem`
      # however for evalModules this will not work, so we do this instead
      nixpkgs.hostPlatform = system;
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
