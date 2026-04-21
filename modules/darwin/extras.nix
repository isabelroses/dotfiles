{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.extersia.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    # keep-sorted end
  ];
}
