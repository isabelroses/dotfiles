{ lib, ... }:
let
  inherit (lib) mkForce mapAttrs;
in
{
  documentation = mapAttrs (_: mkForce) {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
    man = {
      enable = false;
      generateCaches = false;
      man-db.enable = false;
      mandoc.enable = false;
    };
  };
}
