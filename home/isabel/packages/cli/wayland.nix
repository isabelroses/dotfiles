{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  env = osConfig.modules.usrEnv;
  acceptedTypes = ["laptop" "desktop" "hybrid" "lite"];
in {
  config = mkIf ((builtins.elem device.type acceptedTypes) && (env.isWayland)) {
    home.packages = with pkgs; [
      grim
      slurp
      grim
      wl-clipboard
    ];
  };
}
