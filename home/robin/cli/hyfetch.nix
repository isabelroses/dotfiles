{ config, ... }:
{
  programs.hyfetch = {
    inherit (config.garden.profiles.workstation) enable;
  };
}
