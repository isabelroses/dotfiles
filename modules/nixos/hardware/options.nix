{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) listOf str enum;
in
{
  options.garden.device = {
    monitors = mkOption {
      type = listOf str;
      default = [ ];
      description = ''
        this does not affect any drivers and such, it is only necessary for
        declaring things like monitors in window manager configurations
        you can avoid declaring this, but I'd rather if you did declare
      '';
    };

    keyboard = mkOption {
      type = enum [
        "us"
        "gb"
      ];
      default = "gb";
    };
  };
}
