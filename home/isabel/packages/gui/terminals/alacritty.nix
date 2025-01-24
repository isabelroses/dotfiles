{
  lib,
  config,
  osConfig,
  ...
}:
let
  family = osConfig.garden.style.font.name;

  cfg = config.garden.programs.alacritty;
in
{
  programs.alacritty = lib.modules.mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;

    settings = {
      window.opacity = 0.9;

      font = {
        size = 13.0;

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
      };

      cursor.style = {
        shape = "Beam";
        blinking = "Off";
      };
    };
  };
}
