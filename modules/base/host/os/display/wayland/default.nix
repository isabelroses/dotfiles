_: {
  imports = [
    ./environment.nix # configuration for the environment
    ./hyprland.nix # hyprland specific environment configuration
    ./portals.nix # configuration for the xdg desktop portals
    ./services.nix # configuration for the wayland services
  ];
}
