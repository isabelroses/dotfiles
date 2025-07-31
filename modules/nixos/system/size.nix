{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  boot = {
    # this can break things, particularly if you use containers
    # personally I don't so it should be fine to disable this
    enableContainers = false;

    # We enable Systemd in the initrd so we can use it to mount the root
    # filesystem this will remove Perl form the activation
    initrd.systemd.enable = true;
  };

  # Declarative user management
  services.userborn.enable = true;

  environment = {
    # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
    # on NixOS, however we know that so we don't need to see the warning
    stub-ld.enable = false;

    # disable all packages installed by default, i prefer my own packages
    # this list normally includes things like perl
    defaultPackages = mkForce [ ];
  };

  system.etc.overlay.enable = true;

  programs = {
    # this is on by default. but i don't use nano
    nano.enable = false;

    # i don't need less, so lets just remove it, lol
    less = {
      # enabled by default to be the pageer, but i don't use it
      enable = mkForce false;
      lessopen = null; # don't install perl thanks
    };
  };

  # this can allow us to save some storage space
  fonts.fontDir.decompressFonts = true;
}
