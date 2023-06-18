{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  device = config.modules.device;
  acceptedTypes = ["server" "desktop" "laptop" "hybrid" "lite"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    fonts = {
      enableDefaultFonts = false;

      fontconfig = {
        # this fixes emoji stuff
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

      # font packages that should be installed
      fonts = with pkgs; [
        corefonts
        material-icons
        material-design-icons
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        (nerdfonts.override {fonts = ["RobotoMono" "JetBrainsMono" "Mononoki" "Ubuntu" "UbuntuMono" "Noto"];})
      ];
    };
  };
}
