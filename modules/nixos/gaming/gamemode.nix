{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.garden.profiles.gaming.gamemode;
in
{
  options.garden.profiles.gaming.gamemode.enable = mkEnableOption "Gamemode" // {
    default = config.garden.profiles.gaming.enable;
  };

  config.programs.gamemode = mkIf cfg.enable {
    enable = true;
    enableRenice = true;

    settings = {
      general = {
        softrealtime = "auto";
        renice = 15;
      };
    };
  };
}
