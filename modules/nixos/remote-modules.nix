{ inputs, ... }:
{
  imports = [
    inputs.tgirlpkgs.nixosModules.default
  ];
}
