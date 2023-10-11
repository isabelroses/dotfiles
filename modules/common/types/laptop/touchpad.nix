{
  config,
  lib,
  ...
}:
with lib; let
  device = config.modules.device;
in {
  # TODO: touchpads shouldn't be enabled on *all* hybrid devices (server/personal)
  # this should be an option under the device module
  config = mkIf (device.type == "laptop" || device.type == "hybrid") {
    services = {
      # Input settings for libinput
      xserver.libinput = {
        enable = true;

        # disable mouse acceleration
        mouse.accelProfile = "flat";
        mouse.accelSpeed = "0";
        mouse.middleEmulation = false;

        # touchpad settings
        touchpad.naturalScrolling = true;
        touchpad.tapping = true;
        touchpad.clickMethod = "clickfinger";
        touchpad.horizontalScrolling = false;
        touchpad.disableWhileTyping = true;
      };
    };
  };
}
