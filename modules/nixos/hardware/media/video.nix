{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf isx86Linux mkEnableOption;
  cfg = config.modules.system.video;
in
{
  options.modules.system.video.enable = mkEnableOption "Does the device allow for graphical programs";

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = isx86Linux pkgs;
      };
    };

    # benchmarking tools
    environment.systemPackages = with pkgs; [
      glxinfo
      glmark2
    ];
  };
}
