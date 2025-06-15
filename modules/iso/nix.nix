{ inputs', config, ... }:
{
  nix = {
    # setting nix to be our preferred fork
    package = inputs'.izlix.packages.nix;

    # we can disable channels since we can just use the flake
    channel.enable = false;

    # we need to have nixpkgs in our path
    nixPath = [ "nixpkgs=${config.nix.registry.nixpkgs.to.path}" ];

    settings = {
      # these are the bare minimum settings required to get my nixos config working
      experimental-features = [
        "flakes"
        "nix-command"
      ];

      # more logging is nice when doing installs, we want to know if something goes wrong
      log-lines = 50;

      # A unimportant warning in this case
      warn-dirty = false;

      # Its nice to have more http downloads when setting up
      http-connections = 50;

      # We can ignore the flake registry since we won't be using it
      # this is because we already have all the programs we need in the ISO
      flake-registry = "";

      # we don't need this nor do we want it
      accept-flake-config = false;

      # this is not important when your in a ISO
      auto-optimise-store = false;

      # fetch from a cache if we can
      substituters = [
        "https://nix-community.cachix.org" # nix-community cache
        "https://cache.tgirl.cloud/tgirlcloud" # tgirl.cloud cache
        "https://catppuccin.cachix.org" # a cache for all catppuccin ports
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "tgirlcloud:vcV9oxS9pLXyeu1dVnBabLalLlw0yJzu6PakQM372t0="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      ];
    };
  };
}
