{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  documentation = {
    enable = mkForce false;
    dev.enable = mkForce false;
    doc.enable = mkForce false;
    info.enable = mkForce false;
    nixos.enable = mkForce false;

    man = {
      enable = mkForce false;
      generateCaches = mkForce false;
      man-db.enable = mkForce false;
      mandoc.enable = mkForce false;
    };
  };
}
