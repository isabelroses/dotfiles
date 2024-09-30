{ lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) mapAttrs;
in
{
  documentation = mapAttrs (_: mkForce) {
    enable = false;
    info.enable = false;
    doc.enable = false;
  };

  programs = {
    info.enable = false;
    man.enable = false;
  };
}
