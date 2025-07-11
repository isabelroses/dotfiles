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
      defaultFonts =
        let
          fnts = [
            cfg.name
            "Symbols Nerd Font"
            # fallbacks
            "Noto Sans Symbols"
            "Noto Sans Symbols2"
          ];
        in
        {
          monospace = fnts;
          sansSerif = fnts;
          serif = fnts;
          emoji = [
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];
        };
    };

    garden.packages = mkIf (cfg.package != null) {
      ${cfg.package.name} = cfg.package;
    };
  };
}
