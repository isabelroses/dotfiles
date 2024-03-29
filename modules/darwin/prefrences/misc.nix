{
  system.defaults = {
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
      NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
      NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
      NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
      NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
      NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true; # ^
    };

    CustomUserPreferences = {
      # Add a context menu item for showing the Web Inspector in web views
      NSGlobalDomain.WebKitDeveloperExtras = true;

      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
