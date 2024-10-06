{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.programs) mkProgram;
  inherit (lib.types) str;
in
{
  options.garden.programs = {
    wine = mkProgram pkgs "wine" { };
    zathura = mkProgram pkgs "zathura" { };

    discord = mkProgram pkgs "discord" {
      package.default = pkgs.discord.override {
        withOpenASAR = true;
        withVencord = true;
      };
    };

    kdeconnect = mkProgram pkgs "kdeconnect" {
      indicator.enable = mkEnableOption "Enable kdeconnect indicator";
    };

    git = mkProgram pkgs "git" {
      enable.default = config.garden.programs.cli.enable;
      package.default = pkgs.gitFull;

      signingKey = mkOption {
        type = str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };
  };
}
