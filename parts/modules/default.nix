{ self, ... }:
let
  mkModule =
    path: if builtins.isPath path then self + path else builtins.throw "${path} does not exist";
in
{
  flake = {
    homeManagerModules = {
      gtklock = mkModule /modules/extra/home-manager/gtklock.nix;

      hyfetch = mkModule /modules/extra/home-manager/hyfetch.nix;

      # i do not provide a default module, so throw an error
      default = builtins.throw "There is no default module.";
    };
  };
}
