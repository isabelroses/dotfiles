{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.extersia.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    # keep-sorted end
  ];
}
