# in order to reduce our closure size, we can override these packages to use the nix package
# that we have installed, this will trigget a rebuild of the packages that depend on them
# so hopefully its worth it for that system space
{ config, prev, ... }:
let
  useOurNix =
    names:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = prev.${name}.override { nix = config.nix.package; };
      }) names
    );
in
useOurNix [
  "nix-direnv"
  "nix-index"
  "nixos-rebuild"
]
