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
  options.garden.system.video.enable = mkEnableOption "Does the device allow for graphical programs";

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = isx86Linux pkgs;
      };
    };

    # benchmarking tools
    environment.systemPackages = builtins.attrValues { inherit (pkgs) glxinfo glmark2; };
  };
}
