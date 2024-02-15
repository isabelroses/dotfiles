{
  imports = [
    ./environment.nix # configuration for the environment
    ./hyprland.nix # hyprland specific environment configuration
    ./services.nix # configuration for the wayland services
  ];
}
