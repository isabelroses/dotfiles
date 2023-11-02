{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs.fileManagers = {
    dolphin.enable = mkEnableOption "Enable dolphin file manager";
    nemo.enable = mkEnableOption "Enable nemo file manager";
    thunar.enable = mkEnableOption "Enable thunar file manager";
  };
}
