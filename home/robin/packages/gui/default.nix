{
  imports = [
    # package list
    ./shared.nix
    ./wayland.nix

    # configs
    ./gaming
    ./hyprland
    ./wezterm
    ./chromium.nix
    ./discord.nix
    ./ghostty.nix
    ./kitty.nix
    ./obsidian.nix
    ./rofi.nix
    # ./swaync.nix
    ./waybar.nix
    ./zathura.nix
  ];
}
