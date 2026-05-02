{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  services = {
    # monitor and control temperature
    thermald.enable = true;

    # enable smartd monitoring
    smartd.enable = true;

    # Not using lvm
    lvm.enable = mkDefault false;
  };
}
