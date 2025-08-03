{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (config.evergarden) variant;
  palette = inputs.evergarden.lib.palette.${variant};
in
{
  config = mkIf config.garden.profiles.graphical.enable {
    programs.cava = {
      enable = true;
      settings = {

        general = {
          bar_width = 2;
          bar_spacing = 0;
          sensitivity = 80;
        };
        color = {
          gradient = 1;
          gradient_count = 6;
          gradient_color_1 = "'#${palette.skye}'";
          gradient_color_2 = "'#${palette.aqua}'";
          gradient_color_3 = "'#${palette.green}'";
          gradient_color_4 = "'#${palette.lime}'";
          gradient_color_5 = "'#${palette.yellow}'";
          gradient_color_6 = "'#${palette.orange}'";
        };
      };
    };
  };
}
