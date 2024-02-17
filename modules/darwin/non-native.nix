{pkgs, ...}: {
  # Customize settings that not supported by nix-darwin directly
  # see the source code of this project to get more undocumented options:
  #    https://github.com/rgcr/m-cli
  #
  # All custom entries can be found by running `defaults read` command.
  # or `defaults read xxx` to read a specific domain.
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      # Add a context menu item for showing the Web Inspector in web views
      WebKitDeveloperExtras = true;
    };

    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
    };

    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    "com.apple.spaces" = {
      "spans-displays" = 0; # Display have seperate spaces
    };

    "com.apple.WindowManager" = {
      EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
      StandardHideDesktopIcons = 0; # Show items on desktop
      HideDesktop = 0; # Do not hide items on desktop & stage manager
      StageManagerHideWidgets = 0;
      StandardHideWidgets = 0;
    };

    "com.apple.screensaver" = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = 1;
      askForPasswordDelay = 0;
    };

    "com.apple.screencapture" = {
      location = "~/Pictures/screenshots";
      type = "png";
    };

    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };

    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;

    # modified from https://github.com/nmasur/dotfiles/blob/275863795317f8ce65486b138c1fb4eb6dbd65f8/modules/darwin/system.nix#L134-L148
    "com.apple.dock".persistent-apps = let
      dockText = app: "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>${app}</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
    in
      map dockText [
        "/Applications/Arc.app"
        "/Users/isabel/Applications/Home Manager Apps/WezTerm.app"
        "/Users/isabel/Applications/Home Manager Apps/Discord.app"
        "${pkgs.obsidian}/Applications/Obsidian.app"
      ];
  };
}
