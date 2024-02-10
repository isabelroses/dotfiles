{
  self,
  inputs,
  inputs',
  ...
}: {
  nixpkgs = {
    # pkgs = self.legacyPackages.${config.nixpkgs.system};

    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = ["electron-25.9.0"];
    };

    overlays = [
      self.overlays.defaults
      inputs.rust-overlay.overlays.default
      inputs.catppuccin-vsc.overlays.default

      (_: _: {
        nixSchemas = inputs'.nixSchemas.packages.default;
      })
    ];
  };
}
