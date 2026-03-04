{ config, inputs, ... }:
{
  imports = [ inputs.izvim.homeModules.default ];

  programs.izvim = {
    inherit (config.garden.profiles.workstation) enable;
  };
}
