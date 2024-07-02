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

  # we don't need this, plus it adds extra programs to the iso
  services.logrotate.enable = false;

  # disable fontConfig
  fonts.fontconfig.enable = mkForce false;

  # Use environment options, minimal profile
  environment = {
    noXlibs = mkDefault true;

    # we don't really need this warning on the minimal profile
    stub-ld.enable = mkForce false;

    # no packages other, other then the ones I provide
    defaultPackages = [ ];
  };
}
