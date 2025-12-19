{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.garden.device = {
    monitors = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
                description = "the name of the monitor";
                example = "HDMI-1";
              };

              width = mkOption {
                type = types.int;
                default = 1920;
                example = 1080;
                description = "the width of the monitor in pixels";
              };

              height = mkOption {
                type = types.int;
                default = 1080;
                example = 1024;
                description = "the height of the monitor in pixels";
              };

              refresh-rate = mkOption {
                type = types.int;
                default = 60;
                example = 120;
                description = "the refresh rate of the monitor in Hz";
              };

              scale = mkOption {
                type = types.float;
                default = 1.0;
                example = 1.5;
                description = "the scale factor for the monitor";
              };
            };
          }
        )
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
