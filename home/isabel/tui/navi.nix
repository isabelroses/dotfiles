{ config, ... }:
{
  programs.navi = {
    enable = config.garden.profiles.workstation.enable;
  };
}
