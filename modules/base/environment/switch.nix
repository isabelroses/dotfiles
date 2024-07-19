# I would rather use the rust implementation of the switch-to-configuration
# called switch-to-configuration-ng, a thankfully perlless switcher.
# It is a much better, faster and smaller implementation
# WARNING: it is broken on WSL with a PR open to fix it
# https://github.com/NixOS/nixpkgs/pull/321662
{
  system.switch = {
    enable = false; # disable the old implementation
    enableNg = true; # enable the new implementation
  };
}
