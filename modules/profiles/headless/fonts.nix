{ lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) mapAttrs;
in
{
  # we don't need fonts on a server
  # since there are no fonts to be configured outside the console
  fonts = mapAttrs (_: mkForce) {
    packages = [ ];
    fontDir.enable = false;
    fontconfig.enable = false;
  };
}
