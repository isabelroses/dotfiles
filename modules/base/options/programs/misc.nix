{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.types) str;
  inherit (lib.programs) mkProgram;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  options.garden.programs = {
    zathura = mkProgram pkgs "zathura" { };

    discord = mkProgram pkgs "discord" {
      package.default = pkgs.discord.override {
        withOpenASAR = true;
        # discord will by default be wrapped with vencord - the cutest discord client mod
        # go to https://vencord.dev/ for more information
        withVencord = true;
      };
    };

    kdeconnect = mkProgram pkgs "kdeconnect" {
      indicator.enable = mkEnableOption "Enable kdeconnect indicator";
    };

    git = mkProgram pkgs "git" {
      enable.default = config.garden.programs.cli.enable;

      signingKey = mkOption {
        type = str;
        default = "";
        description = "The default gpg key used for signing commits";
      };
    };
  };
}
