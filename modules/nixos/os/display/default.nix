{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.modules.environment;
in
{
  imports = [
    ./wayland

    ./portals.nix # configuration for the xdg desktop portals
  ];

  options.modules.environment = {
    desktop = mkOption {
      type = types.nullOr (
        types.enum [
          "Hyprland"
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
