{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "server" ]) {
    time.timeZone = mkForce "UTC";

    garden = {
      # I still want the nvd diff from rebuilding the servers so lets enable that
      system.activation.diff.enable = true;
    };
  };
}
