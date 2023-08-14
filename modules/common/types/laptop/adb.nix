{
  config,
  lib,
  ...
} @ args:
with lib; let
  device = config.modules.device;
in {
  config = mkIf (device.type == "laptop" || device.type == "hybrid") {
    services = {
      # TODO: move android adb rule elsewhere
      # this should probably be a device or programs option
      udev.extraRules = let
        inherit (import ./plugged.nix args) plugged unplugged;
      in ''
        # add my android device to adbusers
        SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
      '';
    };
  };
}
