{ lib, osConfig, ... }:
{
  xfconf.settings = lib.modules.mkIf osConfig.garden.programs.gui.fileManagers.thunar.enable {
    thunar = {
      "default-view" = "ThunarDetailsView";
      "misc-middle-click-in-tab" = true;
      "misc-open-new-window-as-tab" = true;
      "misc-single-click" = false;
      "misc-volume-management" = false;
    };
  };
}
