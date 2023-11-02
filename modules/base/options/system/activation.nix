{lib, ...}: let
  inherit (lib) mkEnableOption mdDoc;
in {
  options.modules.system.activation = {
    diffGenerations = mkEnableOption (mdDoc "diff view between rebuilds");
  };
}
