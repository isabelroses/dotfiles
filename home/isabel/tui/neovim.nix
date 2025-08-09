{ inputs, config, ... }:
{
  imports = [
    inputs.izvim.homeModules.default
  ];

  programs.izvim = {
    enable = config.garden.profiles.workstation.enable;
    includePerLanguageTooling = true;
    # gui.enable = config.garden.profiles.graphical.enable;
  };
}
