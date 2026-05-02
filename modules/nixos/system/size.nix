{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  environment = {
    # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
    # on NixOS, however we know that so we don't need to see the warning
    stub-ld.enable = false;

    # disable all packages installed by default, i prefer my own packages
    # this list normally includes things like perl
    defaultPackages = mkForce [ ];
  };

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

  # this enables itself on systems that are graphical. but i don't need it this
  # module adds pkgs.speachd which is like 700MiB. we still will have
  # speachd-minmal in our closure due to browsers
  services.speechd.enable = false;
}
