{ lib, osConfig, ... }:
let
  cfg = osConfig.garden.programs.gui.kdeconnect;
in
{
  services.kdeconnect = lib.modules.mkIf cfg.enable {
    enable = true;
    indicator = cfg.indicator.enable;
  };
}
