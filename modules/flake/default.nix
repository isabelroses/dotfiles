inputs:

let

  inherit (inputs) nixpkgs self;
  inherit (nixpkgs) lib;

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  forAllSystems =
    fn:
    lib.genAttrs systems (
      system:
      fn (
        import nixpkgs {
          inherit system;
          overlays = [ inputs.nix-topology.overlays.default ];
        }
      )
    );

  mkHosts = lib.mapAttrs self.lib.mkHost;
in

{
  # a raw unfilted scope of packages
  legacyPackages = forAllSystems (pkgs: import ./packages { inherit pkgs inputs; });

  packages = forAllSystems (
    pkgs:
    lib.filterAttrs (
      _: pkg:
      let
        isDerivation = lib.isDerivation pkg;
        availableOnHost = lib.meta.availableOn pkgs.stdenv.hostPlatform pkg;
        isBroken = pkg.meta.broken or false;
      in
      isDerivation && !isBroken && availableOnHost
    ) self.legacyPackages.${pkgs.stdenv.hostPlatform.system}
  );

  # get a list of packages for the host system, and if none exist use an empty set
  overlays.default = _: prev: self.packages.${prev.stdenv.hostPlatform.system} or { };

  devShells = forAllSystems (pkgs: {
    default = pkgs.callPackage ./programs/shell.nix {
      treefmt-wrapped = self.formatter.${pkgs.stdenv.hostPlatform.system};
    };
  });

  lib = import ./lib { inherit lib inputs; };

  # nix build .#topology.x86_64-linux.config.output
  # nix shell nixpkgs#librsvg
  # rsvg-convert -o docs/src/images/topology.webp ./result/main.svg
  topology = forAllSystems (
    pkgs:
    import inputs.nix-topology {
      inherit pkgs;
      modules = [
        # filter out our iso
        { nixosConfigurations = lib.filterAttrs (k: _: k != "lilith") self.nixosConfigurations; }
        ./programs/topology
      ];
    }
  );

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

    aphrodite = { };

    athena = { };

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
