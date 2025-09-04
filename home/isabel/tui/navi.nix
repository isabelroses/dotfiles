{ config, ... }:
{
  programs.navi = {
    inherit (config.garden.profiles.workstation) enable;
  };
}
