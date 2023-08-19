{inputs, ...}: {
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowUnsupportedSystem = true;
      overlays = [];
    };
  };
}
