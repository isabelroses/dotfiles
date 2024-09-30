{
  imports = [
    # package list
    ./shared.nix
    ./wayland.nix

    # configs
    ./gaming
    ./bars
    ./browsers
    ./fileMangers
    ./launchers
    ./terminals
    ./wm

    ./discord.nix
    ./notes.nix
    ./swaync.nix
    ./viewnior.nix
    ./zathura.nix
  ];
}
