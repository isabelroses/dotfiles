{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.hardware) ldTernary;
in
{
  config.fonts =
    {
      packages = with pkgs; [
        config.garden.style.font.package

        corefonts

        source-sans
        source-serif

        dejavu_fonts
        inter

        noto-fonts

        # fonts for none latin languages
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # install some emoji fonts
        noto-fonts-color-emoji
        material-icons
        material-design-icons

        (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      ];
    }
    // ldTernary pkgs {
      # if we are on linux we should create a fontconfig file
      fontconfig = {
        enable = true;
        hinting.enable = true;
        antialias = true;

        # create all the fonts and set the fallback to the symbols nerd font
        defaultFonts = {
          monospace = [
            config.garden.style.font.name
            "Symbols Nerd Font"
          ];
          sansSerif = [
            config.garden.style.font.name
            "Symbols Nerd Font"
          ];
          serif = [
            config.garden.style.font.name
            "Symbols Nerd Font"
          ];
          emoji = [
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];
        };
      };

      # this can allow us to save some storage space
      fontDir.decompressFonts = true;
    } { };
}
