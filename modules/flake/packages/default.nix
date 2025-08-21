# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code, you may want to add my cachix cache to your flake
# you may want to not have to build this for yourself however
{ lib, inputs, ... }:
{
  # get a list of packages for the host system, and if none exist use an empty set
  flake.overlays.default = _: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system} or { };

  perSystem =
    {
      pkgs,
      self',
      inputs',
      ...
    }:
    let
      packages = lib.makeScope pkgs.newScope (self: {
        inherit inputs;

        # keep-sorted start block=yes newline_separated=yes
        iztaller = self.callPackage ./iztaller/package.nix { nix = inputs'.izlix.packages.lix; };

        libdoc = self.callPackage ./docs/lib.nix { };
        optionsdoc = self.callPackage ./docs/options.nix { };
        docs = self.callPackage ./docs/package.nix { };
        # keep-sorted end
      });
    in
    {
      legacyPackages = packages;

      packages = lib.filterAttrs (
        _: pkg:
        let
          isDerivation = lib.isDerivation pkg;
          availableOnHost = lib.meta.availableOn pkgs.stdenv.hostPlatform pkg;
          isBroken = pkg.meta.broken or false;
        in
        isDerivation && !isBroken && availableOnHost
      ) packages;
    };
}
