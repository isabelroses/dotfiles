{lib, ...}: {
  flake.overlays.default = lib.composeManyExtensions [
    (import ./btop.nix)
    (import ./fish.nix)
    (import ./neovim.nix)
    (import ./ranger.nix)
  ];
}
