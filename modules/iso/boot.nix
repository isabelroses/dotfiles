{ lib, ... }:
let
  inherit (lib.modules) mkForce mkAfter;
in
{
  boot = {
    kernelParams = mkAfter [
      "noquiet"
      "toram"
    ];

    # we don't need to have any raid tools in our system
    swraid.enable = mkForce false;

    supportedFilesystems.zfs = false;
  };
}
