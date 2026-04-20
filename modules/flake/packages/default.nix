# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code.
{ pkgs, inputs, ... }:

pkgs.lib.makeScope pkgs.newScope (self: {
  inherit inputs;

  # keep-sorted start block=yes newline_separated=yes
  docs = self.callPackage ./docs/package.nix { };

  iztaller = self.callPackage ./iztaller/package.nix {
    nix = inputs.izlix.packages.${pkgs.stdenv.hostPlatform.system}.lix;
  };

  libdoc = self.callPackage ./docs/lib.nix { };
  # keep-sorted end
})
