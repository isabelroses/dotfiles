{
  config,
  lib,
  ...
}: let
  cfg = config.isabel;
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  options.isabel.enable = mkEnableOption "base nixos module";

  config = mkIf cfg.enable {
    isabel = {
      desktop.enable = mkEnableOption "enable desktop configuration";
      isNvidia = mkDefault false;
      isLaptop = mkDefault false;
    };
  };
}