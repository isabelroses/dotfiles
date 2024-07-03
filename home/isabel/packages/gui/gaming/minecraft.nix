{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib) isWayland mkIf;

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
in
{
  config = mkIf osConfig.garden.programs.gaming.minecraft.enable {
    home = {
      # PrismLauncher now with a cool theme
      file.".local/share/PrismLauncher/themes/mocha" = {
        source = catppuccin-mocha;
        recursive = true;
      };

      packages =
        let
          glfw = if (isWayland osConfig) then pkgs.glfw-wayland-minecraft else pkgs.glfw;
        in
        [
          (pkgs.prismlauncher.override {
            # get java versions required by various minecraft versions
            # "write once run everywhere" my ass
            jdks = javaPackages;
            additionalPrograms = with pkgs; [
              gamemode
              mangohud
              jprofiler
            ];

            # prismlauncher's glfw version to properly support wayland
            inherit glfw;
          })
        ];
    };
  };
}
