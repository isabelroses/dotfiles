{ lib, ... }:
{
  # disable command-not-found, it doesn't help, and it adds perl
  # which we don't need, and we know when we don't have a command anyway
  programs.command-not-found.enable = false;

  environment = {
    # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
    # on NixOS, however we know that so we don't need to see the warning
    stub-ld.enable = false;

    # disable all packages installed by default, i prefer my own packages
    # this list normally includes things like perl
    defaultPackages = lib.modules.mkForce [ ];
  };
}
