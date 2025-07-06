{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    # keep-sorted start
    ./amd.nix
    ./intel.nix
    # keep-sorted end
  ];

  options.garden.device.cpu = mkOption {
    type = types.nullOr (
      types.enum [
        "intel"
        "vm-intel"
        "amd"
        "vm-amd"
      ]
    );
    default = null;
    description = "The manufacturer of the primary system gpu";
  };
}
