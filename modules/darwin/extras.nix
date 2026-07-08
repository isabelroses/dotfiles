{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.catppuccin.darwinModules.catppuccin
    inputs.extersia.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    # keep-sorted end
  ];
}
