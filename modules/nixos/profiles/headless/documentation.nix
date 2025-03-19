{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (self.lib.validators) hasProfile;
  inherit (lib.attrsets) mapAttrs;
in
{
  config = mkIf (hasProfile config [ "graphical" ]) {
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
  };
}
