{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib) types;
in
{
  options.garden.device = {
    monitors = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            res = mkOption {
              type = types.str;
              default = "1920x1080";
              example = "2560x1440";
              description = "the monitors resolution";
            };

            hz = mkOption {
              type = types.int;
              default = 60;
              example = 144;
              description = "the monitors refresh rate";
            };

            position = mkOption {
              type = types.str;
              default = "auto";
              example = "1920x0";
              description = "the position of the monitor";
            };

            scale = mkOption {
              type = types.str;
              default = "auto";
              example = "1.5";
              description = "the scale of the monitor";
            };
          };
        }
      );

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
      description = ''
        the keyboard layout to use for a given system
      '';
    };
  };
}
