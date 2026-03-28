{ config, ... }:
{
  services.seatd = {
    inherit (config.garden.profiles.graphical) enable;
  };
}
