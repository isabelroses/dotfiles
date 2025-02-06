{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib.hardware) ldTernary;
  inherit (lib.options) mkOption;
  inherit (lib.types) str;

  sys = config.garden.system;
  env = config.garden.environment;
in
{
  options.garden.environment.flakePath = mkOption {
    type = str;
    default = "/${ldTernary pkgs "home" "Users"}/${sys.mainUser}/.config/flake";
    description = "The path to the configuration";
  };

  config.assertions = [
    {
      assertion = sys.useHomeManager -> sys.mainUser != null;
      message = "system.mainUser must be set while useHomeManager is enabled";
    }
    {
      assertion = env.flakePath != null -> sys.mainUser != null;
      message = "system.mainUser must be set if a flakePath is specified";
    }
  ];
}
