{ config, ... }:
{
  services.syncthing = {
    inherit (config.garden.profiles.graphical) enable;
  };
}
