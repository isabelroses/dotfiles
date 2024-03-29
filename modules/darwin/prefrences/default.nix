#  All the configuration options are documented here: https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands: https://macos-defaults.com/
{
  imports = [
    ./clock.nix
    ./dock.nix
    ./finder.nix
    ./login.nix
    ./misc.nix
    ./sound.nix
    ./theme.nix
  ];
}
