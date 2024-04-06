{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.modules.programs.gui.terminals.alacritty.enable {
    programs.alacritty = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        window.opacity = 0.90;

        font = {
          normal = {
            family = "CommitMono";
            style = "Regular";
          };

          bold = {
            family = "CommitMono";
            style = "Bold";
          };

          italic = {
            family = "CommitMono";
            style = "Regular";
          };

          bold_italic = {
            family = "CommitMono";
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
