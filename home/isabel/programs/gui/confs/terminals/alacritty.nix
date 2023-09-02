{
  osConfig,
  lib,
  defaults,
  ...
}: let
  inherit (osConfig.modules.system) video;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.usrEnv.programs.gui.enable && video.enable && defaults.terminal == "alacritty") {
    programs.alacritty = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        window.opacity = 0.90;

        font = {
          normal = {
            family = "RobotoMono Nerd Font Mono";
            style = "Regular";
          };

          bold = {
            family = "RobotoMono Nerd Font Mono";
            style = "Bold";
          };

          italic = {
            family = "RobotoMono Nerd Font Mono";
            style = "Regular";
          };

          bold_italic = {
            family = "RobotoMono Nerd Font Mono";
            style = "Regular Bold";
          };

          size = 13.0;
        };

        cursor = {
          style = {
            shape = "Beam";
            blinking = "Off";
          };
        };

        dynamic_padding = true;
      };
    };
  };
}
