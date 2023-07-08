{
  osConfig,
  lib,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  programs = osConfig.modules.programs;
  sys = osConfig.modules.system;
  acceptedTypes = ["laptop" "desktop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && sys.video.enable) {
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
