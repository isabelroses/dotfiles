{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) ldTernary mkEnableOption mkOption types;

  inherit (config.modules.system) mainUser;
  cfg = config.modules.environment;
in {
  options.modules.environment = {
    useHomeManager = mkEnableOption "Whether to use home-manager or not." // {default = true;};

    flakePath = mkOption {
      type = types.str;
      default = ldTernary pkgs "/home/${mainUser}/.config/flake" "/Users/${mainUser}/.config/flake";
      description = "The path to the configuration";
    };

    desktop = mkOption {
      type = types.nullOr (types.enum ["Hyprland" "Sway"]);
      default = "Hyprland";
      description = "The desktop environment to be used.";
    };

    loginManager = mkOption {
      type = types.nullOr (types.enum ["greetd" "gdm" "lightdm" "sddm"]);
      default = "greetd";
      description = "The login manager to be used by the system.";
    };

    isWayland =
      mkEnableOption "Infered data based on the desktop environment."
      // {
        default = cfg.desktop == "Hyprland" || cfg.desktop == "Sway";
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
