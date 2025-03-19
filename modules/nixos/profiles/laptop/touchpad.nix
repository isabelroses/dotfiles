{
  lib,
  self,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.validators) hasProfile;
in
{
  config = mkIf (hasProfile config [ "laptop" ]) {
    # Input settings for libinput
    services.libinput = {
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
}
