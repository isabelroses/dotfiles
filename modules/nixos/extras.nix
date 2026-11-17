{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.extersia.nixosModules.default
    inputs.home-manager.nixos
    # keep-sorted end
  ];
}
