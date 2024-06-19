{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./amd.nix
    ./intel.nix
  ];

  options.modules.device.cpu = mkOption {
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
