{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  time.timeZone = mkForce "UTC";

  garden = {
    device.type = "server";

    # I still want the nvd diff from rebuilding the servers so lets enable that
    system.activation.diff.enable = true;
  };
}
