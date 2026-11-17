{
  hostSystem,
  root,
}:
/**
  mkHost evaluates one host on the instance for its system, so it takes that
  system's shared nixpkgs. it also assumes the system type is either nixos or
  darwin and uses the appropriate evaluator

  # Type

  ```
  mkHost :: (String -> AttrSet) -> String -> AttrSet -> AttrSet
  ```

  # Example

  ```nix
    mkHost forSystem "myhost" {
      arch = "x86_64";
      class = "nixos";
    }
  ```
*/
forSystem: name:
{
  arch ? "x86_64",
  class ? "nixos",
}:
let
  system = hostSystem { inherit arch class; };

  # the instance for this host's system, it carries the one nixpkgs instance we
  # hand to the host below
  host = forSystem system;
  inherit (host) inputs;
  inherit (inputs) lib pkgs;

  self = host.output;

  evalHost =
    if class == "darwin" then
      import "${inputs.darwin}/eval-config.nix"
    else
      import "${inputs.nixpkgs}/nixos/lib/eval-config.nix";
in
evalHost {
  # nixos would otherwise define `nixpkgs.system` from the evaluating machine,
  # which the read-only nixpkgs module has no option for. nix-darwin takes no
  # such argument
  ${if class == "darwin" then null else "system"} = null;

  # this is the default for nixosSystem but we are really adding it for nix-darwin
  inherit lib;

  # `specialArgs` should only be used for arguments that need to be evaluated
  # when resolving module structure (like in imports). for everything else we
  # have `_module.args`
  specialArgs = {
    inherit
      inputs
      self
      root
      ;
  };

  modules = [
    # import our host system paths
    (root + /systems/${name}/default.nix)

    # import the files required for the class
    (root + /modules/${class}/default.nix)

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

      # every host takes the nixpkgs default.nix already instantiated for its
      # system, rather than creating its own. this is also what puts
      # `self.packages` on the same package set as `pkgs`
      nixpkgs.pkgs = pkgs;
    }
  ]
  # nixos needs to be told that nothing else may configure nixpkgs, nix-darwin
  # has no such module and only asserts that `nixpkgs.config` was left alone
  ++ lib.optional (class != "darwin") "${inputs.nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
  # if we are on darwin we need to import the nixpkgs source, its used in some
  # modules, if this is not set then you will get an error
  ++ lib.optional (class == "darwin") {
    key = "dotfiles#nixpkgs-darwin";
    _file = "${__curPos.file}";

    # without supplying an upstream nixpkgs source, nix-darwin will not be able to build
    # and will complain and log an error demanding that you must set this value
    nixpkgs.source = inputs.nixpkgs.outPath;
  };
}
