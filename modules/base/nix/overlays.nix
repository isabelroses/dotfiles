{ self, inputs, ... }:
{
  nixpkgs.overlays = [
    self.overlays.default
    inputs.rust-overlay.overlays.default
  ];
}
