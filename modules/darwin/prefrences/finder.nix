{
  system.defaults = {
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

    CustomUserPreferences."com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
    };
  };
}
