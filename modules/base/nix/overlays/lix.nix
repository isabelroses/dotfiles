{ self, config, ... }:
{
  nixpkgs.overlays = [
    # this is how we pull in the patches applied to lix, we do it this way such that we can
    # build lix with ci, which is useful
    self.overlays.default

    # in order to reduce our closure size, we can override these packages to use the nix package
    # that we have installed, this will trigget a rebuild of the packages that depend on them
    # so hopefully its worth it for that system space
    (
      _: prev:
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
    )
  ];
}
