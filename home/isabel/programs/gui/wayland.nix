{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  env = osConfig.modules.usrEnv;
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
in {
  config = mkIf (env.isWayland && programs.gui.enable && sys.video.enable) {
    home.packages = with pkgs; [
      swappy
      #swaynotificationcenter
      wlsunset
      wl-gammactl
      pavucontrol
    ];
  };
}
