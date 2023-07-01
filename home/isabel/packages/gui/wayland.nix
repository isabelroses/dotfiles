{
  osConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  env = osConfig.modules.usrEnv;
in {
  config = mkIf (env.isWayland) {
    home.packages = with pkgs; [
      swappy
      #swaynotificationcenter
    ];
  };
}
