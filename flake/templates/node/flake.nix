{
  description = "NodeJS Project Template";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;

    pkgsForEach = nixpkgs.legacyPackages;
  in rec {
    packages = forEachSystem (system: {
      default = pkgsForEach.${system}.callPackage ./default.nix {};
    });

    devShells = forEachSystem (system: {
      default = pkgsForEach.${system}.callPackage ./shell.nix {};
    });

    hydraJobs = packages;
  };
}
