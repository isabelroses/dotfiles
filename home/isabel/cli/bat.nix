{ config, ... }:
{
  programs.bat = {
    # We activate it like this so that catppuccin is applied
    inherit (config.garden.profiles.workstation) enable;
  };
}
