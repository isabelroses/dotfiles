{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.garden.system.boot.plymouth;
in
{
  options.garden.system.boot.plymouth.enable = mkEnableOption "plymouth boot splash";

  config = mkIf cfg.enable {
    boot.plymouth = {
      enable = true;
      catppuccin.enable = true;
    };

    # make plymouth work with sleep
    powerManagement = {
      powerDownCommands = ''
        ${pkgs.plymouth} --show-splash
      '';
      resumeCommands = ''
        ${pkgs.plymouth} --quit
      '';
    };
  };
}
