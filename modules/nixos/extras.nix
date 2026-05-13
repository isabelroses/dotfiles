{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    inputs.extersia.nixosModules.default
    # keep-sorted end
  ];
}
