{ lib, osConfig, ... }:
{
  xfconf.settings = lib.mkIf osConfig.modules.programs.gui.fileManagers.thunar.enable {
    thunar = {
      "default-view" = "ThunarDetailsView";
      "misc-middle-click-in-tab" = true;
      "misc-open-new-window-as-tab" = true;
      "misc-single-click" = false;
      "misc-volume-management" = false;
    };
  };
}
