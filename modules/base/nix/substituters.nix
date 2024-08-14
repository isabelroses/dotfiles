{
  # substituters to use
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/" # official binary cache (yes the trailing slash is really neccacery)
      "https://nix-community.cachix.org" # nix-community cache
      "https://nixpkgs-unfree.cachix.org" # unfree-package cache
      "https://isabelroses.cachix.org" # precompiled binarys from flake
      "https://catppuccin.cachix.org" # a cache for ctp nix
      "https://pre-commit-hooks.cachix.org" # pre commit hooks
      "https://hyprland.cachix.org" # hyprland
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
