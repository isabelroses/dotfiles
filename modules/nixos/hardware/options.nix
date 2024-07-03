{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.garden.device = {
    monitors = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = ''
        this does not affect any drivers and such, it is only necessary for
        declaring things like monitors in window manager configurations
        you can avoid declaring this, but I'd rather if you did declare
      '';
    };

    keyboard = mkOption {
      type = types.enum [
        "us"
        "gb"
      ];
      default = "gb";
    };
  };
}
