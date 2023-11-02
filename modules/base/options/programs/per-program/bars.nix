{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs.bars = {
    ags.enable = mkEnableOption "Enable ags bar";
    eww.enable = mkEnableOption "Enable eww bar";
    waybar.enable = mkEnableOption "Enable waybar";
  };
}
