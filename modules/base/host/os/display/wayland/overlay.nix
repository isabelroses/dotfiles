{
  config,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf (lib.isWayland config) {
    nixpkgs.overlays = with inputs; [
      nixpkgs-wayland.overlay
    ];
  };
}
