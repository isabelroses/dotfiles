{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.garden.system.boot.plymouth;
in
{
  options.garden.system.boot.plymouth.enable = mkEnableOption "plymouth boot splash";

  config = mkIf cfg.enable {
    boot.plymouth.enable = true;

    # make plymouth work with sleep
    powerManagement = {
      powerDownCommands = "${getExe' pkgs.plymouth "plymouth"} --show-splash";
      resumeCommands = "${getExe' pkgs.plymouth "plymouth"} --quit";
    };
  };
}
