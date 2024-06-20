{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.modules.style.font = {
    name = mkOption {
      type = types.str;
      description = "The name of the font";
      default = "Maple Mono";
    };

    package = mkOption {
      type = types.package;
      description = "The package providing the main font";
      default = pkgs.maple-mono;
    };

    size = mkOption {
      type = types.int;
      description = "The size of the font";
      default = 14;
    };
  };
}
