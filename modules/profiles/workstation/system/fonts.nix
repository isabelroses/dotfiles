{pkgs, ...}: {
  config = {
    fonts = {
      enableDefaultPackages = false;

      fontconfig = {
        enable = true;

        defaultFonts = {
          monospace = [
            "RobotoMono Nerd Font Mono"
          ];
          sansSerif = ["Ubuntu Nerd Font"];
          serif = ["Noto Serif"];
          emoji = ["Noto Color Emoji"];
        };
      };

      fontDir = {
        enable = true;
        decompressFonts = true;
      };

      packages = with pkgs; [
        corefonts
        material-icons
        material-design-icons
        dejavu_fonts
        inter
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        (nerdfonts.override {fonts = ["RobotoMono" "JetBrainsMono" "Mononoki" "Ubuntu" "UbuntuMono" "Noto"];})
      ];
    };
  };
}
