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

  config = mkIf (device.type == "laptop" || device.type == "hybrid") {
    hardware.acpilight.enable = true;

    environment.systemPackages = with pkgs; [
      #config.boot.kernelPackages.cpupower
      acpi
      powertop
    ];
  };
}
