{
  config,
  pkgs,
  lib,
  inputs,
  inputs',
  self,
  ...
}: {
  system = {
    autoUpgrade.enable = false;
    stateVersion = lib.mkDefault "23.05";
  };

  environment = {
    etc = with inputs; {
      # set channels (backwards compatibility)
      "nix/flake-channels/system".source = self;
      "nix/flake-channels/nixpkgs".source = nixpkgs;
      "nix/flake-channels/home-manager".source = home-manager;

      # preserve current flake in /etc
      "nixos/flake".source = self;
    };

    # git is reqired for flakes
    systemPackages = [pkgs.git];
  };

  nixpkgs = {
    # pkgs = self.legacyPackages.${config.nixpkgs.system};

    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = ["electron-25.9.0"];
    };

    overlays = [
      self.overlays.defaults
      inputs.rust-overlay.overlays.default
      inputs.catppuccin-vsc.overlays.default

      (_: _: {
        nixSchemas = inputs'.nixSchemas.packages.default;
      })
    ];
  };

  nix = let
    mappedRegistry = lib.pipe inputs [
      (lib.filterAttrs (_: lib.isType "flake"))
      (lib.mapAttrs (_: flake: {inherit flake;}))
      (x: x // {nixpkgs.flake = inputs.nixpkgs;})
    ];
  in {
    # https://github.com/nix-community/home-manager/issues/4692#issuecomment-1848832609
    # package = pkgs.nixVersions.unstable;
    package = pkgs.nixVersions.nix_2_17;

    # pin the registry to avoid downloading and evaluating a new nixpkgs version everytime
    registry = mappedRegistry;

    # We love legacy support (for now)
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    # Make builds run with a low priority, keeping the system fast
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    # set up garbage collection to run daily, and removing packages after 3 days
    gc = {
      automatic = true;
      dates = "Mon *-*-* 03:00";
      options = "--delete-older-than 3d";
    };

    # automatically optimize /nix/store by removing hard links
    optimise = {
      automatic = true;
      dates = ["04:00"];
    };

    settings = {
      # specify the path to the nix registry
      flake-registry = "/etc/nix/registry.json";
      # Free up to 20GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 by 3
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (20 * 1024 * 1024 * 1024)}";
      # automatically optimise symlinks
      auto-optimise-store = pkgs.stdenv.isLinux;
      # allow sudo users to mark the following values as trusted
      allowed-users = ["@wheel"];
      # only allow sudo users to manage the nix store
      trusted-users = ["@wheel"];
      # let the system decide the number of max jobs
      max-jobs = "auto";
      # build inside sandboxed environments
      sandbox = true;
      # supported system features
      system-features = ["nixos-test" "kvm" "recursive-nix" "big-parallel"];
      extra-platforms = config.boot.binfmt.emulatedSystems;
      # continue building derivations even if one fails
      keep-going = true;
      # show more log lines for failed builds, as this happens alot and is useful
      log-lines = 30;
      # enable new nix command and flakes and also "unintended" recursion as well as content addresssed nix
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "repl-flake"
        "auto-allocate-uids"
        "cgroups"
        # "git-hashing"
        # "verified-fetches"
        # "configurable-impure-env"
      ];
      # ignore dirty working tree
      warn-dirty = false;
      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;
      # whether to accept nix configuration from a flake without prompting
      accept-flake-config = true;
      # execute builds inside cgroups
      use-cgroups = true;
      # build from source if the build fails from a binary source
      # fallback = true;

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # substituters to use
      substituters = [
        "https://cache.ngi0.nixos.org" # content addressed nix cache
        "https://cache.nixos.org" # funny binary cache
        "https://nixpkgs-wayland.cachix.org" # some wayland packages
        "https://nix-community.cachix.org" # nix-community cache
        "https://hyprland.cachix.org" # hyprland
        "https://nix-gaming.cachix.org" # nix-gaming
        "https://nixpkgs-unfree.cachix.org" # unfree-package cache
        "https://numtide.cachix.org" # another unfree package cache
        "https://isabelroses.cachix.org" # precompiled binarys from my NUR
        "https://catppuccin.cachix.org" # a cache for ctp nix
        "https://pre-commit-hooks.cachix.org" # pre commit hooks
        "https://cache.garnix.io" # extra things here and there
        "https://ags.cachix.org" # ags
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "isabelroses.cachix.org-1:mXdV/CMcPDaiTmkQ7/4+MzChpOe6Cb97njKmBQQmLPM="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
      ];
    };
  };
}
