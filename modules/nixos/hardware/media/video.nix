{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.hardware) isx86Linux;
  inherit (lib.options) mkEnableOption;
  cfg = config.garden.system.video;
in
{
  options.garden.system.video = {
    enable = mkEnableOption "Does the device allow for graphical programs";

    benchmarking.enable = mkEnableOption "Enable benchmarking tools";
  };

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = isx86Linux pkgs;
      };
    };

    # benchmarking tools
    environment.systemPackages = mkIf cfg.benchmarking.enable (
      builtins.attrValues { inherit (pkgs) mesa-demos glmark2; }
    );
  };
}
