{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.programs = {
    zathura.enable = mkEnableOption "Enable zathura PDF reader";
  };
}
