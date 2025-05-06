{ config, ... }:
{
  programs.zoxide = {
    inherit (config.garden.profiles.workstation) enable;

    options = [ "--cmd cd" ];
  };
}
