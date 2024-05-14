{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.modules.system.printing = {
    enable = mkEnableOption "printing";

    extraDrivers = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "A list of additional drivers to install for printing";
    };
  };
}
