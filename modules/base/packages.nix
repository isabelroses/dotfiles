{
  lib,
  config,
  _class,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) lazyAttrsOf package;
in
{
  options.garden.packages = mkOption {
    type = lazyAttrsOf package;
    default = { };
    description = ''
      A set of packages to install in the garden environment.
    '';
  };

  config = {
    environment.systemPackages = builtins.attrValues config.garden.packages;
  };
}
