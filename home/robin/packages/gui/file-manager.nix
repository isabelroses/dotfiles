{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs;
in
{
  config = mkIf (cfg.gui.enable && !osConfig.garden.meta.isWM) {
    home.packages =
      optionals cfg.cosmic-files.enable [ cfg.cosmic-files.package ]
      ++ optionals cfg.nemo.enable (attrValues {
        inherit (cfg.nemo) package;
        inherit (pkgs) nemo-fileroller nemo-emblems;
      })
      ++ optionals cfg.dolphin.enable [ cfg.dolphin.package ];

    xfconf.settings = mkIf cfg.thunar.enable {
      thunar = {
        "default-view" = "ThunarDetailsView";
        "misc-middle-click-in-tab" = true;
        "misc-open-new-window-as-tab" = true;
        "misc-single-click" = false;
        "misc-volume-management" = false;
      };
    };
  };
}
