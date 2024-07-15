{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) str;
in
{
  options.garden.system.hostname = mkOption {
    type = str;
    description = "The name of the device for the system";
  };
}
