{ inputs, config, ... }:
{
  imports = [
    inputs.izvim.homeModules.default
  ];

  programs.izvim = {
    enable = true;
    includePerLanguageTooling = config.garden.profiles.workstation.enable;
    # gui.enable = config.garden.profiles.graphical.enable;
  };
}
