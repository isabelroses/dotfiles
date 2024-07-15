{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in
{
  sound = mapAttrs (_: mkForce) {
    enable = false; # this just enables ALSA
    mediaKeys.enable = false; # this doesn't actually enable the keys like you might think
    enableOSSEmulation = false; # just a bit quirky
  };
}
