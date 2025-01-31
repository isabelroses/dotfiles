{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf;

  cfg = config.garden.programs;
in
{
  config = mkIf (cfg.gui.enable && !osConfig.garden.meta.isWM) {
    garden.packages =
      optionalAttrs cfg.cosmic-files.enable { inherit (cfg.cosmic-files) package; }
      // optionalAttrs cfg.nemo.enable {
        inherit (cfg.nemo) package;
        inherit (pkgs) nemo-fileroller nemo-emblems;
      }
      // optionalAttrs cfg.dolphin.enable { inherit (cfg.dolphin) package; };

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
