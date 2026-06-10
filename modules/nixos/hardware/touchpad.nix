{ config, ... }:
{
  # Input settings for libinput
  services.libinput = {
    enable = config.garden.profiles.laptop.enable;

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
      disableWhileTyping = true;
    };
  };
}
