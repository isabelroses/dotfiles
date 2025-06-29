{ inputs, config, ... }:
{
  imports = [
    inputs.izvim.homeModules.default
  ];

  garden.programs.neovim.enable = false;

  programs.izvim = {
    enable = true;
    includePerLanguageTooling = config.garden.profiles.workstation.enable;
    # gui.enable = config.garden.profiles.graphical.enable;
  };
}
