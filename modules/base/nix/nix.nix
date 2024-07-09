{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (builtins) attrValues mapAttrs;
  inherit (lib) filterAttrs mkForce ldTernary;

  flakeInputs = filterAttrs (name: value: (value ? outputs) && (name != "self")) inputs;
in
{
  nix = {
    # keep tabs on this for cool new features
    # https://git.lix.systems/lix-project/lix/src/branch/main/doc/manual/rl-next
    package = pkgs.lix;

    # pin the registry to avoid downloading and evaluating a new nixpkgs version everytime
    registry = mapAttrs (_: v: { flake = v; }) flakeInputs;

    # We love legacy support (for now)
    nixPath = ldTernary pkgs (attrValues (mapAttrs (k: v: "${k}=${v.outPath}") flakeInputs)) (
      mkForce (mapAttrs (_: v: v.outPath) flakeInputs)
    );

    # set up garbage collection to run daily, and removing packages after 3 days
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };

    settings = {
      # disable the flake registry since it worsens perf
      flake-registry = pkgs.writers.writeJSON "flakes-empty.json" {
        flakes = [ ];
        version = 2;
      };
      # Free up to 20GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 by 3
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (20 * 1024 * 1024 * 1024)}";
      # automatically optimise symlinks
      # Disable auto-optimise-store because of this issue:
      # https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = pkgs.stdenv.isLinux;
      # allow sudo users to mark the following values as trusted
      allowed-users = [
        "@wheel"
        "root"
        "isabel"
      ];
      # only allow sudo users to manage the nix store
      trusted-users = [
        "@wheel"
        "root"
        "isabel"
      ];
      # let the system decide the number of max jobs
      max-jobs = "auto";
      # build inside sandboxed environments
      sandbox = pkgs.stdenv.isLinux;
      # supported system features
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      # continue building derivations even if one fails
      keep-going = true;
      # show more log lines for failed builds, as this happens alot and is useful
      log-lines = 30;
      # enable new nix command and flakes and also "unintended" recursion as well as content addressed nix
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
        "repl-flake"

        # the below are removed because lix is based on nix 2.18 which did not have these features
        # "git-hashing"
        # "verified-fetches"
        # "configurable-impure-env"
      ];
      # ignore dirty working tree
      warn-dirty = false;
      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;
      # whether to accept nix configuration from a flake without prompting
      # littrally a CVE waiting to happen <https://x.com/puckipedia/status/1693927716326703441>
      accept-flake-config = false;
      # build from source if the build fails from a binary source
      # fallback = true;

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # use xdg base directories
      use-xdg-base-directories = true;
    };
  };
}
