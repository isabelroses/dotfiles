{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  env = osConfig.modules.usrEnv;
  device = osConfig.modules.device;
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && env.isWayland && programs.gui.enable && sys.video.enable) {
    home.packages = with pkgs; [
      swappy
      #swaynotificationcenter
    ];
  };
}
