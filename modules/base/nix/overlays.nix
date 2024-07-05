{ self, inputs, ... }:
{
  nixpkgs.overlays = [
    self.overlays.default
    inputs.beapkgs.overlays.default
    inputs.rust-overlay.overlays.default
  ];
}
