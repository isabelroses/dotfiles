{ config, ... }:
{
  services.seatd = {
    enable = config.garden.profiles.graphical.enable && !config.services.desktopManager.cosmic.enable;
  };
}
