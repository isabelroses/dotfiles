{ inputs', ... }:
{
  nixpkgs.overlays = [
    (_: _: { inherit (inputs'.nixpkgs-wsl.legacyPackages) switch-to-configuration-ng; })
  ];
}
