{
  lib,
  self,
  config,
  ...
}:
let
  inherit (self.lib.validators) hasProfile;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkIf mkForce;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
    xdg = mapAttrs (_: mkForce) {
      sounds.enable = false;
      mime.enable = false;
      menus.enable = false;
      icons.enable = false;
      autostart.enable = false;
    };
  };
}
