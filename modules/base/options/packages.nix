{ lib, config, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf package;
in
{
  options.garden.packages = mkOption {
    type = attrsOf package;
    default = { };
    description = ''
      A set of packages to install in the garden environment.
    '';
  };

  config = {
    environment.systemPackages = builtins.attrValues config.garden.packages;
  };
}
