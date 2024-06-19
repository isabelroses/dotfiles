{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    ldTernary
    mkEnableOption
    mkOption
    types
    ;

  inherit (config.modules.system) mainUser;
in
{
  options.modules.environment = {
    useHomeManager = mkEnableOption "Whether to use home-manager or not" // {
      default = true;
    };

    flakePath = mkOption {
      type = types.str;
      default = "/${ldTernary pkgs "home" "Users"}/${mainUser}/.config/flake";
      description = "The path to the configuration";
    };
  };

  config.assertions = [
    {
      assertion = config.modules.environment.useHomeManager -> config.modules.system.mainUser != null;
      message = "system.mainUser must be set while useHomeManager is enabled";
    }
    {
      assertion = config.modules.environment.flakePath != null -> config.modules.system.mainUser != null;
      message = "system.mainUser must be set if a flakePath is specified";
    }
  ];
}
