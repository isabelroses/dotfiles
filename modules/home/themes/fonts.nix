{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types)
    str
    int
    package
    nullOr
    ;

  cfg = config.garden.style.fonts;
in
{
  options.garden.style.fonts = {
    enable = mkEnableOption "fontconfig" // {
      default = config.garden.profiles.graphical.enable;
    };

    name = mkOption {
      type = str;
      description = "The name of the font";
      default = "Maple Mono";
    };

    italic = mkOption {
      type = str;
      description = "The name of the italic font";
      default = "Maple Mono Italic";
    };

    bold = mkOption {
      type = str;
      description = "The name of the bold font";
      default = "Maple Mono Bold";
    };

    bold-italic = mkOption {
      type = str;
      description = "The name of the bold italic font";
      default = "Maple Mono Bold Italic";
    };

    package = mkOption {
      type = nullOr package;
      description = "The package that provides the font";
      default = pkgs.maple-mono.truetype;
    };

    size = mkOption {
      type = int;
      description = "The size of the font";
      default = 14;
    };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;

      # create all the fonts and set the fallback to the symbols nerd font
      defaultFonts = {
        monospace = [
          cfg.name

          # primary latin fallbacks
          "Source Code Pro"

          # unicode coverage
          "Noto Sans Mono"
          "Noto Sans"
          "Noto Serif"

          # CJK coverage
          "Noto Sans CJK JP"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK KR"

          # icon fonts
          "Material Icons"
          "Material Design Icons"

          # final fallback
          "DejaVu Sans Mono"
        ];

        sansSerif = [
          cfg.name

          # primary latin fallbacks
          "Inter"
          "Source Sans 3"

          # unicode coverage
          "Noto Sans"

          # CJK
          "Noto Sans CJK JP"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK KR"

          # icons
          "Material Icons"
          "Material Design Icons"

          # final fallback
          "DejaVu Sans"
        ];

        serif = [
          cfg.name

          # latin serif
          "Source Serif 4"

          # unicode coverage
          "Noto Serif"

          # CJK
          "Noto Serif CJK JP"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK KR"

          # icons
          "Material Icons"
          "Material Design Icons"

          # final fallback
          "DejaVu Serif"
        ];

        emoji = [
          "Twemoji Color Font"
          "Noto Color Emoji"
        ];
      };
    };

    garden.packages = mkIf (cfg.package != null) {
      ${cfg.package.name} = cfg.package;
    };
  };
}
