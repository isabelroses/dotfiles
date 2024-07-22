{
  lib,
  config,
  inputs',
  ...
}:
let
  inherit (lib.lists) optionals;
  inherit (config.garden.device) type;
in
{
  nixpkgs.overlays = optionals (type == "wsl") [
    (_: _: { inherit (inputs'.nixpkgs-wsl.legacyPackages) switch-to-configuration-ng; })
  ];
}
