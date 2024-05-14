{ lib, ... }:
let
  inherit (lib) mkDefault mkForce;
in
{
  # disable sound related programs
  sound.enable = false;

  # disable documentation
  documentation = {
    enable = mkDefault false;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
  };

  # disable fontConfig
  fonts.fontconfig.enable = mkForce false;

  # Use environment options, minimal profile
  environment = {
    noXlibs = mkDefault true;

    # no packages other, other then the ones I provide
    defaultPackages = [ ];
  };
}
