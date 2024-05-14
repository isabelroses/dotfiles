{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.programs.gui.kdeconnect;
in
{
  services.kdeconnect = lib.mkIf cfg.enable {
    enable = true;
    indicator = cfg.indicator.enable;
  };
}
