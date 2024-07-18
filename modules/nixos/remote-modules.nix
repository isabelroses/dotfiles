{ inputs, ... }:
{
  imports = [
    inputs.beapkgs.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];
}
