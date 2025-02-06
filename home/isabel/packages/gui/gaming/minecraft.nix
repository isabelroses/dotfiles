{
  lib,
  self,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) isWayland;

  catppuccin-mocha = pkgs.fetchzip {
    url = "https://github.com/PrismLauncher/Themes/releases/download/2024-04-01_1711994750/Catppuccin-Mocha-theme.zip";
    hash = "sha256-BMJBJnIZZTP8l0O+8yOGSyW4S3SNOACa5ja/mqTRyzA=";
  };
in
{
  config = mkIf osConfig.garden.programs.gaming.minecraft.enable {
    home = {
      # PrismLauncher now with a cool theme
      file.".local/share/PrismLauncher/themes/mocha" = {
        source = catppuccin-mocha;
        recursive = true;
      };

      packages = [
        (pkgs.prismlauncher.override {
          # get java versions required by various minecraft versions
          # "write once run everywhere" my ass
          jdks = builtins.attrValues {
            inherit (pkgs)
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
              ;
          };

          additionalPrograms = builtins.attrValues { inherit (pkgs) gamemode mangohud jprofiler; };

          # prismlauncher's glfw version to properly support wayland
          glfw = if (isWayland osConfig) then pkgs.glfw-wayland-minecraft else pkgs.glfw;
        })
      ];
    };
  };
}
