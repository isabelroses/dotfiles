# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code.
{ pkgs, inputs, ... }:

let
  inherit (pkgs) lib;

  scope = pkgs.lib.makeScope pkgs.newScope (scopeSelf: {
    inherit (inputs) self;

    # keep-sorted start block=yes newline_separated=yes
    formatting = scopeSelf.callPackage ./formatting.nix { };

    # lib = scopeSelf.callPackage ./lib.nix { };
    # keep-sorted end
  });

in

lib.filterAttrs (_: lib.isDerivation) scope
