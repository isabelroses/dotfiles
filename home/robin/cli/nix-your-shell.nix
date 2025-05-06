{ config, ... }:
{
  programs.nix-your-shell = {
    inherit (config.garden.profiles.workstation) enable;
  };
}
