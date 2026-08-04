{ lib, config, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.profiles.oracle = {
    enable = mkEnableOption "Oracle Cloud profile";
  };

  config = lib.mkIf config.garden.profiles.oracle.enable {
    services.thermald.enable = mkForce false; # Unavailable - device lacks thermal sensors.
  };
}
