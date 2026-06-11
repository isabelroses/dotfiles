{
  pkgs,
  sources,
}:
{
  # needs no changes
  inherit (sources) nixpkgs darwin;

  # don't care for the packages; just the modules
  home-manager = {
    nixosModules.home-manager = "${sources.home-manager}/nixos";
    darwinModules.home-manager = "${sources.home-manager}/nix-darwin";
  };

  # only need the modules here
  sops = {
    nixosModules.sops = "${sources.sops}/modules/sops";
    homeManagerModules.sops = "${sources.sops}/modules/home-manager/sops.nix";
  };

  # don't care for the packages here. catppuccin.sources exposes all we need
  catppuccin = {
    nixosModules.catppuccin = "${sources.catppuccin}/modules/nixos";
    homeModules.catppuccin = "${sources.catppuccin}/modules/home-manager";
  };

  # already exposes a flake like output schema
  lanzaboote = import sources.lanzaboote {
    inherit pkgs;
    inherit (pkgs.stdenv.hostPlatform) system;
  };

  # no packages; just need the module
  simple-nixos-mailserver.nixosModules.default = import sources.simple-nixos-mailserver;

  # we only need the module here
  homebrew.darwinModules.nix-homebrew = "${sources.homebrew}/modules";

  # already exposes flake like schema
  spicetify = import sources.spicetify { inherit pkgs; };

  # already exposes flake like schema
  extersia = {
    outPath = sources.extersia;
  }
  // import sources.extersia { inherit pkgs; };

  # only construct packages. output schema is packages only
  izlix = {
    outPath = sources.izlix;
    packages = import sources.izlix { inherit pkgs; };
  };

  # only exposes packages
  izvim.packages = import sources.izvim { inherit pkgs; };
}
