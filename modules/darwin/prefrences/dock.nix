{
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0; # autohide delay
      autohide-time-modifier = 1.0; # autohide animation duration

      orientation = "bottom"; # dock position
      tilesize = 1; # dock icon size

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
