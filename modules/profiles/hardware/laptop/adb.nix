args: {
  config = {
    services = {
      udev.extraRules = let
        inherit (import ./plugged.nix args) plugged unplugged;
      in ''
        # add my android device to adbusers
        SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
      '';
    };
  };
}
