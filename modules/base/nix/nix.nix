{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.attrsets) filterAttrs attrValues mapAttrs;
  inherit (lib.modules) mkForce;
  inherit (lib.hardware) ldTernary;

  flakeInputs = filterAttrs (name: value: (value ? outputs) && (name != "self")) inputs;
in
{
  nix = {
    # keep tabs on this for cool new features
    # https://git.lix.systems/lix-project/lix/src/branch/main/doc/manual/rl-next
    #
    # You cannot build nix.exe with lix, I don't really know who this affects but...
    # https://akko.isabelroses.com/notice/AjMDXG28c8sLqhci0G
    #
    # NOTE: we are also using a specifically patched version, you can see this from overlays/lix.nix
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

    # https://docs.lix.systems/manual/lix/nightly/command-ref/conf-file.html
    settings = {
      # Free up to 20GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 by 3
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (20 * 1024 * 1024 * 1024)}";

      # automatically optimise symlinks
      # Disable auto-optimise-store because of this issue:
      # https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = pkgs.stdenv.isLinux;

      # we need to create some trusted and allwed users so that we can use 
      # some features like substituters
      allowed-users = [
        "@wheel" # allow sudo users to mark the following values as trusted
        "root"
        "isabel"
      ];
      trusted-users = [
        "@wheel" # allow sudo users to manage the nix store
        "root"
        "isabel"
      ];

      # disallow the use of flake registries to resolve flake references
      use-registries = false;

      # let the system decide the number of max jobs
      max-jobs = "auto";

      # build inside sandboxed environments
      # we only enable this on linux because it servirly breaks on darwin
      sandbox = pkgs.stdenv.isLinux;

      # supported system features
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];

      # continue building derivations even if one fails
      # this is important for keeping a nice cache of derivations, usually because I walk away 
      # from my PC when building and it would be annoying to deal with nothing saved
      keep-going = true;

      # show more log lines for failed builds, as this happens alot and is useful
      log-lines = 30;

      # https://docs.lix.systems/manual/lix/nightly/contributing/experimental-features.html
      extra-experimental-features = [
        # enables flakes, needed for this config
        "flakes"

        # enables the nix3 commands, a requirement for flakes
        "nix-command"

        # allow nix to call itself
        "recursive-nix"

        # allow nix to build and use content addressable derivations, these are nice beaccase
        # they prevent rebuilds when changes to the derivation do not result in changes to the derivation's output
        "ca-derivations"

        # Allows Nix to automatically pick UIDs for builds, rather than creating nixbld* user accounts
        # which is BEYOND annoying, which makes this a really nice feature to have
        "auto-allocate-uids"

        # allows Nix to execute builds inside cgroups
        # remember you must also enable use-cgroups in the nix.conf or settings
        "cgroups"

        # allow passing installables to nix repl, making its interface consistent with the other experimental commands
        "repl-flake"

        # disallow unquoted URLs as part of the Nix language syntax
        # this are explicitly derpricated and are unused in nixpkgs, so we should ensure that we are not using them
        "no-url-literals"
      ];

      # don't warn me if the current working tree is dirty
      # i don't need the warning because i'm working on it right now
      warn-dirty = false;

      # the defaults to false even if the experimental feature is enabled
      # so we need to enable it here, this is also only available on linux, so we should check for that
      use-cgroups = pkgs.stdenv.isLinux;

      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;

      # whether to accept nix configuration from a flake without prompting
      # littrally a CVE waiting to happen <https://x.com/puckipedia/status/1693927716326703441>
      accept-flake-config = false;

      # build from source if the build fails from a binary source
      # fallback = true;

      # this defaults to true, however it slows down evaluation so maybe we should disable it
      # some day, but we do need it for catppuccin/nix so maybe not too soon
      allow-import-from-derivation = true;

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # use xdg base directories for all the nix things
      use-xdg-base-directories = true;
    };
  };
}
