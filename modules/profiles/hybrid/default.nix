{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  imports = [
    ../laptop
    ../server
  ];

  garden.device.type = mkForce "hybrid";
}
