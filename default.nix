{
  sources ? import ./npins,
  nixpkgs ? sources.nixpkgs,
  system ? builtins.currentSystem,
  lib ? import "${sources.nixpkgs}/lib",
  pkgs ? import nixpkgs { inherit system; },
}:
let
  outPath = ./modules/flake;
  importOutput = path: import (outPath + path);

  mkHost = import ./eval-config.nix { inherit lib sources; };
  mkHosts = lib.mapAttrs mkHost;
in
lib.fix (self: {
  inputs =
    import ./flake-npins-shim.nix {
      inherit pkgs sources;
    }
    // {
      # lets access self. but we don't want to endlessly add inputs to self or we will IR
      self = (lib.removeAttrs self [ "inputs" ]) // {
        outPath = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.gitTracked ./.;
        };
      };
    };

  # a raw unfilted scope of packages
  packages = importOutput /packages {
    inherit pkgs;
    inherit (self) inputs;
  };

  devShells.default = pkgs.callPackage (outPath + /programs/shell.nix) {
    treefmt-wrapped = self.formatter;
  };

  lib = importOutput /lib {
    inherit lib;
    inherit (self) inputs;
  };

  checks = importOutput /checks {
    inherit pkgs;
    inherit (self) inputs;
  };

  formatter = pkgs.callPackage (outPath + /programs/formatter.nix) { };

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
})
