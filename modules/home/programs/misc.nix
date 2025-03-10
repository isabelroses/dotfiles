{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (self.lib.programs) mkProgram;
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.programs = {
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

    cocogitto = mkProgram pkgs "cocogitto" {
      enable.default = config.garden.programs.cli.enable;
    };
  };
}
