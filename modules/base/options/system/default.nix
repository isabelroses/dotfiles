{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.garden.system.hostname = mkOption {
    type = types.str;
    description = "The name of the device for the system";
  };
}
