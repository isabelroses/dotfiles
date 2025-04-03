{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkMerge;
  inherit (self.lib.hardware) isx86Linux;
  inherit (lib.options) mkEnableOption;
  cfg = config.garden.system.video;
in
{
  options.garden.system.video = {
    enable = mkEnableOption "Does the device allow for graphical programs";

    benchmarking.enable = mkEnableOption "Enable benchmarking tools";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = isx86Linux pkgs;
      };
    }

    # benchmarking tools
    (mkIf cfg.benchmarking.enable {
      garden.packages = {
        inherit (pkgs) glmark2 mesa-demos;
      };
    })
  ]);
}
