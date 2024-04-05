{
  system.defaults.CustomUserPreferences = {
    "com.apple.screensaver" = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = 1;
      askForPasswordDelay = 0;
    };

    "com.apple.screencapture" = {
      location = "~/Pictures/screenshots";
      type = "png";
    };

    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
  };
}
