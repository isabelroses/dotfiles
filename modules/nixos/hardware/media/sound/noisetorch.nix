{ config, ... }:
{
  programs.noisetorch.enable = config.garden.profiles.graphical.enable;
}
