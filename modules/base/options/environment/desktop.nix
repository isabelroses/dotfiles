{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.modules.environment;
in
{
  options.modules.environment = {
    desktop = mkOption {
      type = types.nullOr (
        types.enum [
          "Hyprland"
          "yabai"
          "sway"
        ]
      );
      default = "Hyprland";
      description = "The desktop environment to be used.";
    };

    isWayland = mkEnableOption "Inferred data based on the desktop environment." // {
      default = cfg.desktop == "Hyprland" || cfg.desktop == "Sway";
    };
  };
}
