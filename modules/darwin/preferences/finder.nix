{
  system.defaults = {
    finder = {
      # show full path in finder title
      _FXShowPosixPathInTitle = true;

      # remove items from trash after 30 days
      # FXRemoveOldTrashItems = true;

      # show all file extensions
      AppleShowAllExtensions = true;

      # show hidden files
      AppleShowAllFiles = true;

      # disable warning when changing file extension
      FXEnableExtensionChangeWarning = false;

      # hide the quit button on finder
      QuitMenuItem = true;

      # show path bar
      ShowPathbar = true;

      # show status bar
      ShowStatusBar = true;

      # disable icons on the desktop
      CreateDesktop = false;
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
