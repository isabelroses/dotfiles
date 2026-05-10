{ pkgs, inputs, ... }:

let
  inherit (pkgs) lib;

  scope = lib.makeScope pkgs.newScope (scopeSelf: {
    inherit (inputs) self;

    # keep-sorted start block=yes newline_separated=yes
    formatting = scopeSelf.callPackage ./formatting.nix { };

    port-collector = scopeSelf.callPackage ./port-collector.nix { };

    selflib = scopeSelf.callPackage ./lib.nix { };
    # keep-sorted end
  });

in

lib.filterAttrs (_: lib.isDerivation) scope
