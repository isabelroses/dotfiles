{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.system.activation = {
    diffGenerations = mkEnableOption "diff view between rebuilds";
  };
}
