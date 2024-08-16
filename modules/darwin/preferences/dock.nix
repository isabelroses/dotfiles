{
  system.defaults = {
    dock = {
      autohide = true;

      # autohide delay
      autohide-delay = 0.0;

      # autohide animation duration
      autohide-time-modifier = 1.0;

      # dock position
      orientation = "bottom";

      # dock icon size
      tilesize = 1;

      # show running apps
      static-only = false;

      # disable recent apps
      show-recents = false;

      # show hidden apps
      showhidden = false;

      # disable recent spaces
      mru-spaces = false;

      # customize Hot Corners
      #  1: Disabled
      #  2: Mission Control
      #  3: Application Windows
      #  4: Desktop
      #  5: Start Screen Saver
      #  6: Disable Screen Saver
      #  7: Dashboard
      #  10: Put Display to Sleep
      #  11: Launchpad
      #  12: Notification Center
      #  13: Lock Screen
      #  14: Quick Note
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };
  };

  # CustomUserPreferences = {
  #   modified from https://github.com/nmasur/dotfiles/blob/275863795317f8ce65486b138c1fb4eb6dbd65f8/modules/darwin/system.nix#L134-L148
  #   "com.apple.dock".persistent-apps = let
  #     dockText = app: "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>'${app}'</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
  #   in
  #     map dockText [
  #       "/Applications/Arc.app"
  #       "/Users/isabel/Applications/Home Manager Apps/WezTerm.app"
  #       "/Users/isabel/Applications/Home Manager Apps/Discord.app"
  #       "${pkgs.obsidian}/Applications/Obsidian.app"
  #     ];
  # };
}
