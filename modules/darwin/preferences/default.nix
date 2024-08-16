# All the configuration options are documented here: https://daiderd.com/nix-darwin/manual/index.html#sec-options
# Incomplete list of macOS `defaults` commands: https://macos-defaults.com/
#
# This pertains to anything prefixed with CustomUserPreferences
# Customize settings that not supported by nix-darwin directly
# see the source code of this project to get more undocumented options:
#    https://github.com/rgcr/m-cli
#
# All custom entries can be found by running `defaults read` command.
# or `defaults read xxx` to read a specific domain.
{
  imports = [
    ./clock.nix # Settings for the clock in the menu bar
    ./dock.nix # Settings for the dock
    ./finder.nix # Settings for Finder (file manager)
    ./images.nix # Screensaver, screenshots etc
    ./login.nix # Settings for the login screen
    ./measurements.nix # Units and measurements
    ./misc.nix # Miscellaneous settings
    ./sound.nix # Sound settings
    ./theme.nix # Theme settings
    ./wm.nix # Window manager settings
  ];
}
