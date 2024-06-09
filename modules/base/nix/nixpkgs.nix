{
  lib,
  self,
  inputs,
  ...
}:
{
  nixpkgs = {
    # pkgs = self.legacyPackages.${config.nixpkgs.system};

    config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "emojis" ];
      allowBroken = false;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [ "electron-25.9.0" ];
    };

    overlays = [
      self.overlays.default
      inputs.beapkgs.overlays.default
      inputs.rust-overlay.overlays.default
    ];
  };
}
