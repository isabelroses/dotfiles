{ inputs, ... }:
{
  imports = [
    inputs.tgirlpkgs.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
  ];
}
