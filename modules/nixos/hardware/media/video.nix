{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf isx86Linux mkEnableOption;
  sys = config.modules.system;
in
{
  options.modules.system.video.enable = mkEnableOption "Does the device allow for graphical programs";

  config = mkIf sys.video.enable {
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = isx86Linux pkgs;
      };
    };

    # benchmarking tools
    environment.systemPackages = with pkgs; [
      glxinfo
      glmark2
    ];
  };
}
