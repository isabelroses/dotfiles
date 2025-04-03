{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.trivial) id;
  inherit (lib.options) mkOption;
  inherit (self.lib.validators) anyHome;
  inherit (lib.strings) concatStringsSep;

  mkMetaOption =
    path:
    mkOption {
      default = anyHome config id path;
      example = true;
      description = "Does ${concatStringsSep "." path} meet the requirements";
      type = lib.types.bool;
    };
in
{
  options.garden.meta = {
    zsh = mkMetaOption [
      "garden"
      "programs"
      "zsh"
      "enable"
    ];
    fish = mkMetaOption [
      "garden"
      "programs"
      "fish"
      "enable"
    ];
    kdeconnect = mkMetaOption [
      "garden"
      "programs"
      "kdeconnect"
      "enable"
    ];
    gui = mkMetaOption [
      "garden"
      "programs"
      "gui"
      "enable"
    ];

    isWayland = mkMetaOption [
      "garden"
      "meta"
      "isWayland"
    ];
    isWM = mkMetaOption [
      "garden"
      "meta"
      "isWM"
    ];

    hyprland =
      let
        path = [
          "garden"
          "environment"
          "desktop"
        ];
      in
      mkOption {
        default = anyHome config (v: v == "Hyprland") path;
        example = true;
        description = "Does ${concatStringsSep "." path} meet the requirements";
        type = lib.types.bool;
      };
  };
}
