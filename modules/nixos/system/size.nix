{ lib, ... }:
{
  # this can break things, particularly if you use containers
  # personally I don't so it should be fine to disable this
  boot.enableContainers = false;

  # Declarative user management
  services.userborn.enable = true;

  # We enable Systemd in the initrd so we can use it to mount the root
  # filesystem this will remove Perl form the activation
  boot.initrd.systemd.enable = true;

  environment = {
    # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
    # on NixOS, however we know that so we don't need to see the warning
    stub-ld.enable = false;

    # disable all packages installed by default, i prefer my own packages
    # this list normally includes things like perl
    defaultPackages = lib.mkForce [ ];
  };

  # this can allow us to save some storage space
  fonts.fontDir.decompressFonts = true;
}
