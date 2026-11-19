{ config, ... }:
{
  hardware.graphics.enable =
    config.garden.profiles.graphical.enable || config.garden.device.gpu != null;
}
