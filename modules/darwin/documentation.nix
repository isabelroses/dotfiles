{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  documentation = {
    enable = mkForce false;
    info.enable = mkForce false;
    doc.enable = mkForce false;
  };

  programs = {
    info.enable = mkForce false;
    man.enable = mkForce false;
  };
}
