{ inputs, ... }:
{
  systems = import inputs.systems;

  perSystem =
    { system, ... }:
    {
      # this is what controls how packages in the flake are built, but this is not passed to the
      # builders in lib which is important to note, since we have to do something different for
      # the builders to work correctly
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [ ];
      };
    };
}
