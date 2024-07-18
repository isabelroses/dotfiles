{ inputs, ... }:
{
  imports = [
    inputs.beapkgs.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
  ];
}
