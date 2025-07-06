{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.home-manager.nixosModules.home-manager
    inputs.tgirlpkgs.nixosModules.default
    # keep-sorted end
  ];
}
