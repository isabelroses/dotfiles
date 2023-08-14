{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with lib; let
  dev = osConfig.modules.device;
  vid = osConfig.modules.system.video;
  env = osConfig.modules.usrEnv;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem dev.type acceptedTypes && env.screenLock == "gtklock") && (vid.enable && env.isWayland)) {
    programs.gtklock = {
      enable = true;
      package = pkgs.gtklock;

      config = {
        modules = [
          "${pkgs.gtklock-powerbar-module.outPath}/lib/gtklock/powerbar-module.so"
          "${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so"
        ];

        style = pkgs.writeText "gtklock-style.css" ''
          window {
            font-family: Product Sans;
          }
          entry {
            border-radius: 19px;
            box-shadow: 0 1px 3px rgba(0,0,0,.1);
          }
        '';
      };

      extraConfig = {};
    };
  };
}
