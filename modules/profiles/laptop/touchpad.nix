{
  config,
  lib,
  ...
}: let
  inherit (config.modules) device;
in {
  config = lib.mkIf (device.type == "laptop" || device.type == "hybrid") {
    services = {
      # Input settings for libinput
      xserver.libinput = {
        enable = true;

        # disable mouse acceleration (yes im gamer)
        mouse = {
          accelProfile = "flat";
          accelSpeed = "0";
          middleEmulation = false;
        };

        # touchpad settings
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
          horizontalScrolling = false;
          disableWhileTyping = true;
        };
      };
    };
  };
}
