{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.modules.environment = {
    useHomeManager = mkEnableOption "Whether to use home-manager or not." // {default = true;};

    flakePath = mkOption {
      type = types.str;
      default = "/home/${config.modules.system.mainUser}/.config/flake";
      description = "The path to the configuration";
    };

    desktop = mkOption {
      type = types.enum ["Hyprland" "Sway"];
      default = "Hyprland";
      description = "The desktop environment to be used.";
    };

    loginManager = mkOption {
      type = types.nullOr (types.enum ["greetd" "gdm" "lightdm" "sddm"]);
      default = "greetd";
      description = "The login manager to be used by the system.";
    };

    isWayland = mkEnableOption "Infered data based on the desktop environment." // {default = config.modules.environment.desktop == "Hyprland";};
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
