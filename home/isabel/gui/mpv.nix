{ config, ... }:
{
  programs.mpv = {
    inherit (config.garden.profiles.graphical) enable;
  };
}
