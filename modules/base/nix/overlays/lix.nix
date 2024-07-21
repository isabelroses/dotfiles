{ self, config, ... }:
{
  nixpkgs.overlays = [
    # this is how we pull in the patches applied to lix, we do it this way such that we can
    # build lix with ci, which is useful
    self.overlays.default

    (_: prev: {
      # in order to reduce our closure size, we can override these packages to use the nix package
      # that we have installed, this will trigget a rebuild of the packages that depend on them
      # so hopefully its worth it for that system space
      nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };
      nix-index = prev.nix-index.override { nix = config.nix.package; };

      # NOTE: this is not installed because i have a almost perlless system setup
      # but this will remain here incase i change my mind
      nixos-rebuild = prev.nixos-rebuild.override { nix = config.nix.package; };
    })
  ];
}
