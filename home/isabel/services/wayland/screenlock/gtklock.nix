{
  pkgs,
  lib,
  config,
  osConfig,
  defaults,
  ...
}:
let
  inherit (lib) mkIf;
  dev = osConfig.modules.device;
  vid = osConfig.modules.system.video;
  env = osConfig.modules.usrEnv;

  acceptedTypes = ["desktop" "laptop" "lite" "hybrid"];
in {
  config = mkIf ((builtins.elem dev.type acceptedTypes && defaults.screenLock == "gtklock") && (vid.enable && env.isWayland)) {
    programs.gtklock = {
      enable = true;
      package = pkgs.gtklock;

      config = {
        modules = [
          "${pkgs.gtklock-powerbar-module.outPath}/lib/gtklock/powerbar-module.so"
        ];

        style = pkgs.writeText "gtklock-style.css" ''
          window {
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
          }


          #clock-label {
            margin-bottom: 30px;
            font-size: 800%;
            font-weight: bold;
            color: white;
            text-shadow: 0px 2px 10px rgba(0,0,0,.1)
          }

          #body {
            margin-top: 50px;
          }

          #unlock-button {
            all: unset;
            color: transparent;
          }

          entry {
            border-radius: 12px;
            margin: 1px;
            box-shadow: 1px 2px 4px rgba(0,0,0,.1)
          }

          #input-label {
            color: transparent;
            margin: -20rem;
          }

          #powerbar-box * {
            border-radius: 12px;
            box-shadow: 1px 2px 4px rgba(0,0,0,.1)
          }
        '';
      };

      extraConfig = {};
    };
  };
}
