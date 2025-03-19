{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum listOf;
in
{
  options.garden.device.profiles = mkOption {
    type = listOf (enum [
      # physical
      "laptop"
      "desktop"
      "server"
      "wsl"
      "vm"

      # meta
      "lite"
      "graphical"
      "headless"
    ]);
    default = [ ];
  };
}
