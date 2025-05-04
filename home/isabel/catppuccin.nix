{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  catppuccinLib = import (inputs.catppuccin + "/modules/lib") {
    config = { };
    inherit lib pkgs;
  };
in
{
  options.catppuccin = {
    enable = lib.mkEnableOption "Catppuccin globally";

    flavor = lib.mkOption {
      type = catppuccinLib.types.flavor;
      default = "mocha";
      description = "Global Catppuccin flavor";
    };

    accent = lib.mkOption {
      type = catppuccinLib.types.accent;
      default = "sapphire";
      description = "Global Catppuccin accent";
    };
  };
}
