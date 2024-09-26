{ lib, ... }:
let
  inherit (lib.modules) mkForce mkDefault;
in
{
  # disable documentation
  documentation = {
    enable = mkDefault false;
    doc.enable = mkDefault false;
    info.enable = mkDefault false;
  };

  # we don't need this, plus it adds extra programs to the iso
  services = {
    logrotate.enable = false;
    udisks2.enable = false;
  };

  # disable fontConfig
  fonts.fontconfig.enable = mkForce false;

  # disable containers as it also pulls in pearl
  boot.enableContainers = false;

  programs = {
    # disable less as it pulls in pearl
    less.lessopen = null;

    # disable command-not-found and other similar programs
    command-not-found.enable = false;
  };

  # Use environment options, minimal profile
  environment = {
    # we don't really need this warning on the minimal profile
    stub-ld.enable = mkForce false;

    # no packages other, other then the ones I provide
    defaultPackages = [ ];
  };

  xdg = {
    autostart.enable = false;
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
