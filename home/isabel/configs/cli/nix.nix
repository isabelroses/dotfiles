{ lib, osConfig, ... }:
let
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.lists) elem;
in
{
  # copy the system config for nix to the home-manager config
  # you might think "WHY????" well so did I, turns out if you want nix to use
  # xdg dirs from the user level you better set this up since home-manager
  # checks the home-manger level nix config for symlinking dirs and some other stuff
  nix = filterAttrs (
    name: _:
    elem name [
      "nixPath"
      "settings"
      "registry"
    ]
  ) osConfig.nix;
}
