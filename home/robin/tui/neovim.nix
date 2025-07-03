{ inputs, config, ... }:
{
  imports = [
    inputs.ivy.homeModules.default
  ];

  programs.ivy = {
    enable = true;
    includePerLanguageTooling = config.garden.profiles.workstation.enable;
    gui.enable = config.garden.profiles.graphical.enable;
  };
}
