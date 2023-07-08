{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  env = osConfig.modules.usrEnv;
  sys = osConfig.modules.system;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (env.isWayland && sys.video.enable)) {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
    ];
  };
}
