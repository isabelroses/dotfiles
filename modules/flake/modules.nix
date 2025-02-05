{ self, ... }:
let
  inherit (builtins) throw;
in
{
  modules = {
    nixos = {
      garden = {
        imports = [
          (self + /modules/base/default.nix)
          (self + /modules/nixos/default.nix)
        ];
      };

      # i do not provide a default module, so throw an error
      default = throw "There is no default module.";
    };

    darwin = {
      garden = {
        imports = [
          (self + /modules/base/default.nix)
          (self + /modules/darwin/default.nix)
        ];
      };

      default = throw "There is no default module.";
    };

    homeManager = {
      gtklock = self + /modules/extra/home-manager/gtklock.nix;

      hyfetch = self + /modules/extra/home-manager/hyfetch.nix;

      garden = self + /modules/home/default.nix;

      default = throw "There is no default module.";
    };
  };
}
