{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    # keep-sorted start
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
    # keep-sorted end
  ];

  options.garden.device.gpu = mkOption {
    type = types.nullOr (
      types.enum [
        "amd"
        "intel"
        "nvidia"
      ]
    );
    default = null;
    description = "The manufacturer of the primary system gpu";
  };
}
