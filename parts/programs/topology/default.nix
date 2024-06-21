{ inputs, ... }:
{
  imports = [
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "topology";
        file = ./default.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
  ];

  # nix build .#topology.x86_64-linux.config.output
  perSystem =
    { config, ... }:
    {
      topology = import inputs.nix-topology {
        pkgs = config.legacyPackages;
        modules = [
          ./output.nix
          { inherit (inputs.self) nixosConfigurations; }
        ];
      };
    };
}
