{
  lib,
  pkgs,
  osConfig,
  ...
}: let
  catppuccin-mocha = pkgs.fetchzip {
    url = "https://raw.githubusercontent.com/catppuccin/prismlauncher/main/themes/Mocha/Catppuccin-Mocha.zip";
    sha256 = "8uRqCoe9iSIwNnK13d6S4XSX945g88mVyoY+LZSPBtQ=";
  };

  javaPackages = with pkgs; [
    # Java 8
    temurin-jre-bin-8
    zulu8
    # Java 11
    temurin-jre-bin-11
    # Java 17
    temurin-jre-bin-17
    # Latest
    temurin-jre-bin
    zulu
    graalvm-ce
  ];
in {
  config = lib.mkIf osConfig.modules.programs.gaming.minecraft.enable {
    home = {
      # PrismLauncher now with a cool theme
      file.".local/share/PrismLauncher/themes/mocha" = {
        source = catppuccin-mocha;
        recursive = true;
      };

      packages = [
        (pkgs.prismlauncher.override {
          jdks = javaPackages;
        })
      ];
    };
  };
}
