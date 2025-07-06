{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.home-manager.darwinModules.home-manager
    inputs.tgirlpkgs.darwinModules.default
    # keep-sorted end
  ];
}
