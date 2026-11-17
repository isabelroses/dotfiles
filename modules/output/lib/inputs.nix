# what we take out of each source, for one system. an input is whatever we need
# from a source: the modules, the packages, or the whole upstream expression,
# named the way upstream names it. every input also carries the `outPath` of
# its source, so it can stand in for the source itself
{ lib }:
sources: system:
let
  # one nixpkgs per system, shared by every host and output on that system
  pkgs = import sources.nixpkgs {
    inherit system;
    config = import ../nixpkgs.nix;
    overlays = [ ];
  };

  taken = {
    home-manager = {
      nixos = "${sources.home-manager}/nixos";
      darwin = "${sources.home-manager}/nix-darwin";
    };

    sops = {
      nixos = "${sources.sops}/modules/sops";
      home = "${sources.sops}/modules/home-manager/sops.nix";
    };

    # don't care for the packages here. catppuccin.sources exposes all we need
    catppuccin = {
      nixos = "${sources.catppuccin}/modules/nixos";
      home = "${sources.catppuccin}/modules/home-manager";
      darwin = "${sources.catppuccin}/modules/darwin";
    };

    simple-nixos-mailserver.nixos = sources.simple-nixos-mailserver.outPath;

    homebrew.darwin = "${sources.homebrew}/modules";

    # already exposes the modules and packages under upstream's own names
    lanzaboote = import sources.lanzaboote { inherit pkgs system; };

    spicetify = import sources.spicetify { inherit pkgs; };

    extersia = import sources.extersia { inherit pkgs; };

    izlix = import sources.izlix { inherit pkgs; };

    izvim = import sources.izvim { inherit pkgs; };
  };
in
lib.mapAttrs (name: source: taken.${name} or { } // { inherit (source) outPath; }) (
  # npins also hands us a `__functor`, which is not a source
  lib.filterAttrs (_: source: source ? outPath) sources
)
// {
  inherit pkgs lib;
}
