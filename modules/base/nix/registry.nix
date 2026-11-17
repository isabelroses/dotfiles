{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib.attrsets) attrValues mapAttrs;
  inherit (lib.modules) mkForce mkIf;

  pinnedSources = mapAttrs (_: input: { inherit (input) outPath; }) (
    removeAttrs inputs [
      "lib"
      "pkgs"
    ]
  );
in
{
  # The path to the nixpkgs sources used to build the system. This is
  # automatically set up to be the store path of the nixpkgs flake used to
  # build the system if using lib.nixosSystem, and is otherwise null by
  # default.
  #
  # now i actually set this back to null, because i want to do what this pr
  # does basically. nowhere is this option really used outside of the one
  # module so i can pretty much just null it and be fine
  # https://github.com/NixOS/nixpkgs/pull/388090
  nixpkgs.flake.source = mkForce null;

  # now the explanation is done above we can pin our nixpkgs and sources
  # however we like
  #
  # a pin keeps the source in the closure, and nixpkgs alone is over
  # 200MiB, so headless hosts go without; nothing is evaluated on them
  nix = mkIf (!config.garden.profiles.headless.enable) {
    # pin to avoid downloading and evaluating a new source everytime
    registry = mapAttrs (_: flake: { inherit flake; }) pinnedSources;
    nixPath = attrValues (mapAttrs (k: v: "${k}=flake:${v.outPath}") pinnedSources);
  };
}
