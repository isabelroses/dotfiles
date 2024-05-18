{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in
{
  sound = mapAttrs (_: mkForce) {
    enable = false;
    mediaKeys.enable = false;
    enableOSSEmulation = false;
  };
}
