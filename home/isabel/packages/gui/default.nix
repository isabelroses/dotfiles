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
    ./terminals
    ./wm

    ./discord.nix
    ./file-manager.nix
    ./notes.nix
    ./swaync.nix
    ./viewnior.nix
    ./zathura.nix
  ];
}
