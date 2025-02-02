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
    ./obsidian.nix
    # ./swaync.nix
    ./zathura.nix
  ];
}
