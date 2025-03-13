{ self, ... }:
let
  inherit (builtins) throw;

  mkModule =
    {
      name ? "garden",
      class,
      modules,
    }:
    {
      _class = class;
      _file = "${self.outPath}/flake.nix#${class}Modules.${name}";

      imports = modules;
    };
in
{
  flake = {
    nixosModules = {
      garden = mkModule {
        class = "nixos";
        modules = [
          (self + /modules/base/default.nix)
          (self + /modules/nixos/default.nix)
        ];
      };

      # i do not provide a default module, so throw an error
      default = throw "There is no default module.";
    };

    darwinModules = {
      garden = {
        class = "darwin";
        modules = [
          (self + /modules/base/default.nix)
          (self + /modules/darwin/default.nix)
        ];
      };

      default = throw "There is no default module.";
    };

    homeManagerModules = {
      garden = mkModule {
        class = "homeManager";
        modules = [ (self + /modules/home/default.nix) ];
      };

      gtklock = mkModule {
        name = "gtklock";
        class = "homeManager";
        modules = [ (self + /modules/extra/home-manager/gtklock.nix) ];
      };

      hyfetch = mkModule {
        name = "gtklock";
        class = "homeManager";
        modules = [ (self + /modules/extra/home-manager/hyfetch.nix) ];
      };

      default = throw "There is no default module.";
    };
  };
}
