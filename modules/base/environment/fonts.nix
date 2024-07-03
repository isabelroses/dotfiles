{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) ldTernary;
in
{
  config.fonts =
    {
      packages = with pkgs; [
        config.garden.style.font.package

        corefonts

        material-icons
        material-design-icons

        source-sans
        source-serif

        dejavu_fonts
        inter

        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji

        (nerdfonts.override {
          fonts = [
            "NerdFontsSymbolsOnly"
            "RobotoMono"
            "JetBrainsMono"
            "Mononoki"
            "Ubuntu"
            "UbuntuMono"
          ];
        })
      ];
    }
    // ldTernary pkgs {
      fontconfig = {
        enable = true;
        hinting.enable = true;
        antialias = true;

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

      fontDir.decompressFonts = true;
    } { };
}
