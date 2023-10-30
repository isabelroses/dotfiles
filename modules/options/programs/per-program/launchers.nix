{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs.launchers = {
    rofi.enable = mkEnableOption "Enable rofi launcher";
    wofi.enable = mkEnableOption "Enable wofi launcher";
  };
}
