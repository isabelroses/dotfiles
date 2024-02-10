{pkgs, ...}: {
  config = {
    fonts = {
      enableDefaultPackages = false;

      fontconfig = {
        enable = true;

        defaultFonts = {
          monospace = ["RobotoMono Nerd Font Mono"];
          sansSerif = ["Roboto Nerd Font"];
          serif = ["Noto Serif"];
          emoji = ["Noto Color Emoji"];
        };
      };

      # will be removed after this PR is merged:
      # https://github.com/LnL7/nix-darwin/pull/754
      fontDir = {
        enable = true;
        decompressFonts = true;
      };

      packages = with pkgs; [
        corefonts

        material-icons
        material-design-icons

        source-sans
        source-serif

        dejavu_fonts
        inter

        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji

        (nerdfonts.override {
          fonts = [
            "NerdFontsSymbolsOnly"
            "RobotoMono"
            "JetBrainsMono"
            "Mononoki"
            "Ubuntu"
            "UbuntuMono"
            "Noto"
          ];
        })
      ];
    };
  };
}
