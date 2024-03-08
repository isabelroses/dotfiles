#  All the configuration options are documented here: https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands: https://macos-defaults.com/
{
  system.defaults = {
    loginwindow = {
      GuestEnabled = false; # disable guest user
      SHOWFULLNAME = false; # show full name in login window
    };

    menuExtraClock = {
      Show24Hour = true; # show 12 hour clock
      IsAnalog = false; # show digital clock
      ShowAMPM = true; # show AM/PM

      # Show date can imply the result of ShowDayOfMonth, ShowDayOfWeek, and ShowSeconds.
      ShowDate = 2; # 0 = Show the date 1 = Don’t show 2 = Don’t show (hides date)
      # ShowDayOfMonth = false; # show day of month
      # ShowDayOfWeek = false; # show day of week
      # ShowSeconds = false; # show seconds
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0; # autohide delay
      autohide-time-modifier = 1.0; # autohide animation duration

      orientation = "bottom"; # dock position
      tilesize = 0; # dock icon size

      static-only = false; # show running apps
      show-recents = false; # disable recent apps
      showhidden = false; # show hidden apps
      mru-spaces = false; # disable recent spaces

      # customize Hot Corners
      # wvous-tl-corner = 2; # top-left - Mission Control
      # wvous-tr-corner = 13; # top-right - Lock Screen
      # wvous-bl-corner = 3; # bottom-left - Application Windows
      # wvous-br-corner = 4; # bottom-right - Desktop
    };

    finder = {
      _FXShowPosixPathInTitle = true; # show full path in finder title
      # FXRemoveOldTrashItems = true; # remove items from trash after 30 days
      AppleShowAllExtensions = true; # show all file extensions
      AppleShowAllFiles = true; # show hidden files
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
      QuitMenuItem = true; # hide the quit button on finder
      ShowPathbar = true; # show path bar
      ShowStatusBar = true; # show status bar

      # cusomize the desktop
      CreateDesktop = false; # disable icons on the desktop
    };

    NSGlobalDomain = {
      AppleICUForce24HourTime = false; # use 12 hour time

      "com.apple.swipescrolldirection" = false; # enable natural scrolling
      "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
      "com.apple.sound.beep.volume" = null; # disable beep sound
      "com.apple.keyboard.fnState" = true; # use function keys as standard function keys

      AppleInterfaceStyle = "Dark"; # dark mode
      AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.

      ApplePressAndHoldEnabled = false; # enable press and hold
      # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
      # This is very useful for vim users, they use `hjkl` to move cursor.
      # sets how long it takes before it starts repeating.
      InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
      # sets how fast it repeats once it starts.
      KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

      NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
      NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
      NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
      NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
      NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
      NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true; # ^
    };
  };
}
