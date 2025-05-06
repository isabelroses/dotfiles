{ config, ... }:
{
  programs = {
    # disable command-not-found, it doesn't help, and it adds perl
    # which we don't need, and we know when we don't have a command anyway
    command-not-found.enable = false;

    # like `thefuck`, but in rust and actually maintained
    pay-respects.enable = config.garden.profiles.graphical.enable;
  };
}
