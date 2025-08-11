{ inputs, config, ... }:
{
  imports = [
    inputs.izvim.homeModules.default
  ];

  programs.izvim = {
    inherit (config.garden.profiles.workstation) enable;
    includePerLanguageTooling = true;
    # gui.enable = config.garden.profiles.graphical.enable;
  };
}
