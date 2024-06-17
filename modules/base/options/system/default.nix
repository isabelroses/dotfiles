{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.modules.system = {
    hostname = mkOption {
      type = types.str;
      description = "The name of the device for the system";
    };
  };
}
