{
  system.defaults = {
    NSGlobalDomain = {
      # disable auto capitalization
      NSAutomaticCapitalizationEnabled = false;

      # disable auto dash substitution
      NSAutomaticDashSubstitutionEnabled = false;

      # disable auto period substitution
      NSAutomaticPeriodSubstitutionEnabled = false;

      # disable auto quote substitution
      NSAutomaticQuoteSubstitutionEnabled = false;

      # disable auto spelling correction
      NSAutomaticSpellingCorrectionEnabled = false;

      # expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
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
