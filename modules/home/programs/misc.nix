{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption;
  inherit (self.lib) mkProgram;

  cfg = config.garden.programs.discord;
in
{
  options.garden.programs = {
    discord = mkProgram pkgs "discord" {
      withVencord = mkEnableOption "Enable Vencord";
      withMoonlight = mkEnableOption "Enable Moonlight";
      withOpenASAR = mkEnableOption "Enable OpenASAR";
    };
  };

  config = {
    garden.programs.discord = {
      package = pkgs.discord.override {
        inherit (cfg) withVencord withMoonlight withOpenASAR;
      };
    };

    assertions = [
      {
        assertion = cfg.withOpenASAR -> cfg.withMoonlight;
        message = "Moonlight and OpenASAR are mutually exclusive. Please enable only one of them.";
      }
      {
        assertion = cfg.withVencord -> cfg.withMoonlight;
        message = "Moonlight and Vencord are mutually exclusive. Please enable only one of them.";
      }
    ];
  };
}
