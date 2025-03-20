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
  config = mkIf (hasProfile config [ "headless" ]) {
    # we don't need fonts on a server
    # since there are no fonts to be configured outside the console
    fonts = mapAttrs (_: mkForce) {
      packages = [ ];
      fontDir.enable = false;
      fontconfig.enable = false;
    };
  };
}
