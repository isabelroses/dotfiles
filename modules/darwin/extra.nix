{ inputs, ... }:
{
  imports = [
    inputs.tgirlpkgs.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
  ];
}
