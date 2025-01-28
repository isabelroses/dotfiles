{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) getAttrFromPath;
  inherit (lib.lists) elem;
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr enum;

  mkMetaOption =
    path: enum:
    mkOption {
      default = elem (getAttrFromPath path config) enum;
      example = true;
      description = "Does ${enum} contain ${getAttrFromPath path}.";
      type = lib.types.bool;
    };
in
{
  options.garden = {
    environment.desktop = mkOption {
      type = nullOr (enum [
        "Hyprland"
        "yabai"
        "sway"
        "cosmic"
      ]);
      default = "Hyprland";
      description = "The desktop environment to be used.";
    };

    meta = {
      isWayland = mkMetaOption [ "garden" "environment" "desktop" ] [ "Hyprland" "sway" "cosmic" ];
      isWM = mkMetaOption [ "garden" "environment" "desktop" ] [ "yabai" "sway" "cosmic" ];
    };
  };

  config.garden = {
    programs.defaults = mkIf (config.garden.environment.desktop == "cosmic") {
      fileManager = "cosmic-files";
      launcher = "cosmic-launcher";
    };
  };
}
