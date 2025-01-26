{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.hardware) ldTernary;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str;

  inherit (config.garden.system) mainUser;
  env = config.garden.environment;
in
{
  options.garden.environment = {
    useHomeManager = mkEnableOption "Whether to use home-manager or not" // {
      default = true;
    };

    flakePath = mkOption {
      type = str;
      default = "/${ldTernary pkgs "home" "Users"}/${mainUser}/.config/flake";
      description = "The path to the configuration";
    };
  };

  config.assertions = [
    {
      assertion = env.useHomeManager -> mainUser != null;
      message = "system.mainUser must be set while useHomeManager is enabled";
    }
    {
      assertion = env.flakePath != null -> mainUser != null;
      message = "system.mainUser must be set if a flakePath is specified";
    }
  ];
}
