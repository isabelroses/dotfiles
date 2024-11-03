{ lib, config, ... }:
let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr enum;

  cfg = config.garden.environment;
in
{
  options.garden.environment = {
    desktop = mkOption {
      type = nullOr (enum [
        "Hyprland"
        "yabai"
        "sway"
        "cosmic"
      ]);
      default = "Hyprland";
      description = "The desktop environment to be used.";
    };

    isWayland = mkEnableOption "Inferred data based on the desktop environment." // {
      default = cfg.desktop == "Hyprland" || cfg.desktop == "sway" || cfg.desktop == "cosmic";
    };

    isWM = mkEnableOption "Inferred data based on the desktop environment." // {
      default = cfg.desktop == "Hyprland" || cfg.desktop == "sway";
    };
  };
}
