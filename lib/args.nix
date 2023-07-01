{inputs, ...}: let
  inherit (inputs.nixpkgs);
in {
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
      overlays = [];
    };
  };
}
