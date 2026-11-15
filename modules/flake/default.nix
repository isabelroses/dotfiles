inputs:

let

  inherit (inputs) nixpkgs self;
  inherit (nixpkgs) lib;

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # one nixpkgs per system, shared by every host and every output below, so
  # nothing gets evaluated on a second instance
  pkgsFor = lib.attrsets.genAttrs systems (
    system:
    import nixpkgs {
      inherit system;
      config = import ./nixpkgs.nix;
      overlays = [ ];
    }
  );

  forAllSystems = fn: lib.attrsets.mapAttrs (_: fn) pkgsFor;

  mkHosts = lib.attrsets.mapAttrs self.lib.mkHost;
in

{
  # a raw unfilted scope of packages
  legacyPackages = forAllSystems (pkgs: import ./packages { inherit pkgs inputs; });

  devShells = forAllSystems (pkgs: {
    default = pkgs.callPackage ./programs/shell.nix {
      treefmt-wrapped = self.formatter.${pkgs.stdenv.hostPlatform.system};
    };
  });

  lib = import ./lib { inherit lib inputs pkgsFor; };

  checks = forAllSystems (pkgs: import ./checks { inherit pkgs inputs; });

  formatter = forAllSystems (pkgs: pkgs.callPackage ./programs/formatter.nix { });

  # This is the list of system configuration
  #
  # the defaults consists of the following:
  #  arch = "x86_64";
  #  class = "nixos";
  nixosConfigurations = mkHosts {
    # keep-sorted start block=yes newline_separated=yes
    amaterasu = { };

    freyja = { };

    isis = { };

    lilith = {
      class = "iso";
    };

    minerva = { };

    skadi = {
      arch = "aarch64";
    };
    # keep-sorted end
  };

  darwinConfigurations = mkHosts {
    # keep-sorted start block=yes newline_separated=yes
    tatsumaki = {
      arch = "aarch64";
      class = "darwin";
    };
    #keep-sorted end
  };
}
