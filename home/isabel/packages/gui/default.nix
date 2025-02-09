{
  imports = [
    # package list
    ./shared.nix
    ./wayland.nix

    # configs
    ./gaming
    ./bars
    ./browsers
    ./launchers
    ./screenlock
    ./terminals
    ./wm

    ./discord.nix
    ./notes.nix
    ./swaync.nix
    ./zathura.nix
  ];
}
