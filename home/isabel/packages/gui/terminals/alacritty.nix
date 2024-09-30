{ lib, osConfig, ... }:
{
  config = lib.modules.mkIf osConfig.garden.programs.gui.terminals.alacritty.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 0.9;

        font =
          let
            family = osConfig.garden.style.font.name;
          in
          {
            normal = {
              inherit family;
              style = "Regular";
            };

            bold = {
              inherit family;
              style = "Bold";
            };

            italic = {
              inherit family;
              style = "Regular";
            };

            bold_italic = {
              inherit family;
              style = "Regular Bold";
            };

            size = 13.0;
          };

        cursor.style = {
          shape = "Beam";
          blinking = "Off";
        };
      };
    };
  };
}
