{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "headless" ]) {
    # a headless system should not mount any removable media
    # without explicit user action
    services.udisks2.enable = lib.modules.mkForce false;
  };
}
