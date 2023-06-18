{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  sys = config.modules.system;
in {
  config = mkIf (sys.video.enable) {
    hardware = {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    };

    # benchmarking tools
    environment.systemPackages = with pkgs; [
      glxinfo
      glmark2
    ];
  };
}
