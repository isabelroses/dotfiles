{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  import = [ ./greetd.nix ];

  options.modules.environment.loginManager = mkOption {
    type = types.nullOr (
      types.enum [
        "greetd"
        "gdm"
        "lightdm"
        "sddm"
      ]
    );
    default = "greetd";
    description = "The login manager to be used by the system.";
  };
}
