{ lib, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr enum;
in
{

  options.garden = {
    environment.desktop = mkOption {
      type = nullOr (enum [
        "aerospace"
        "yabai"
      ]);
      default = null;
      description = "The desktop environment to be used.";
    };
  };
}
