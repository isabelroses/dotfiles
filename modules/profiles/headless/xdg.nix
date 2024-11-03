{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkForce;
in
{
  xdg = mapAttrs (_: mkForce) {
    sounds.enable = false;
    mime.enable = false;
    menus.enable = false;
    icons.enable = false;
    autostart.enable = false;
  };
}
