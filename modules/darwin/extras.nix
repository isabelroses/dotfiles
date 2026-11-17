{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.catppuccin.darwin
    inputs.extersia.darwinModules.default
    inputs.home-manager.darwin
    # keep-sorted end
  ];
}
