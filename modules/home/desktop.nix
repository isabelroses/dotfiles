{
  lib,
  self,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf mkOptionDefault;
  inherit (lib.attrsets) getAttrFromPath;
  inherit (lib.lists) elem;
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr enum;
  inherit (self.lib.validators) hasProfile;

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
        "sway"
        "cosmic"
      ]);
      description = "The desktop environment to be used.";
    };

    meta = {
      isWayland = mkMetaOption [ "garden" "environment" "desktop" ] [ "Hyprland" "sway" "cosmic" ];
      isWM = mkMetaOption [ "garden" "environment" "desktop" ] [ "sway" "cosmic" ];
    };
  };

  config.garden = {
    programs.defaults = mkIf (config.garden.environment.desktop == "cosmic") {
      fileManager = "cosmic-files";
      launcher = "cosmic-launcher";
    };

    environment = {
      desktop = mkOptionDefault (if (hasProfile osConfig [ "graphical" ]) then null else "Hyprland");
    };
  };
}
