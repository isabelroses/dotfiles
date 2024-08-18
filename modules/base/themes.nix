{ lib, pkgs, ... }:
let
  inherit (lib.options) mkOption mkPackageOption;
  inherit (lib.types) str int;
in
{
  options.garden.style.font = {
    name = mkOption {
      type = str;
      description = "The name of the font";
      default = "Maple Mono";
    };

    package = mkPackageOption pkgs "maple-mono" { };

    size = mkOption {
      type = int;
      description = "The size of the font";
      default = 14;
    };
  };
}
