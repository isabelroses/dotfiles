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

  fleet =
    (lib.modules.evalModules {
      modules = [
        {
          options.hosts = lib.options.mkOption {
            type = lib.types.attrsOf (lib.types.submodule "${self}/systems/fleet.nix");
          };
          config.hosts = lib.trivial.importTOML "${self}/systems/fleet.toml";
        }
      ];
    }).config.hosts;
  hosts = lib.lists.partition (host: host.value.class == "darwin") (
    lib.lists.filter (host: host.value.class != "unmanaged") (lib.attrsets.attrsToList fleet)
  );
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

  # nix build .#topology.x86_64-linux.config.output
  # nix shell nixpkgs#librsvg
  # rsvg-convert -o docs/src/images/topology.webp ./result/main.svg
  topology = lib.attrsets.genAttrs systems (
    system:
    import inputs.nix-topology {
      # only topology needs the overlay, so don't re-instantiate nixpkgs for every output
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-topology.overlays.default ];
      };
      modules = [
        # filter out our iso
        { nixosConfigurations = lib.attrsets.filterAttrs (k: _: k != "lilith") self.nixosConfigurations; }
        ./programs/topology
      ];
    }
  );

  checks = forAllSystems (pkgs: import ./checks { inherit pkgs inputs; });

  formatter = forAllSystems (pkgs: pkgs.callPackage ./programs/formatter.nix { });

  nixosConfigurations = mkHosts (lib.attrsets.listToAttrs hosts.wrong);
  darwinConfigurations = mkHosts (lib.attrsets.listToAttrs hosts.right);
}
