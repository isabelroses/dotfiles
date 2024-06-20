{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) ldTernary;

  fnts = with pkgs; [
    config.modules.style.font.package

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
in
{
  config.fonts =
    {
      # will be removed after this PR is merged:
      # https://github.com/LnL7/nix-darwin/pull/754
      fontDir.enable = true;
    }
    // ldTernary pkgs {
      fontconfig = {
        enable = true;
        hinting.enable = true;
        antialias = true;

        defaultFonts = {
          monospace = [
            config.modules.style.font.name
            "Symbols Nerd Font"
          ];
          sansSerif = [
            config.modules.style.font.name
            "Symbols Nerd Font"
          ];
          serif = [
            config.modules.style.font.name
            "Symbols Nerd Font"
          ];
          emoji = [
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];
        };
      };

      packages = fnts;

      fontDir.decompressFonts = true;
    } { fonts = fnts; };
}
