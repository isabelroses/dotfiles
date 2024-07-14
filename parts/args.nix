{ inputs, ... }:
{
  systems = import inputs.systems;

  perSystem =
    { config, system, ... }:
    {
      _module.args.pkgs = config.legacyPackages;

      legacyPackages = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [ ];
      };
    };
}
