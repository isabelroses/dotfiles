{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  imports = [
    ./power
    ./adb.nix
    ./touchpad.nix
  ];

  config =
    mkIf (device.type == "laptop" || device.type == "hybrid") {
    };
}
