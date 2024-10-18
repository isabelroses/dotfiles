{
  imports = [
    ./environment.nix # configuration for the environment
    ./hyprland.nix # hyprland specific environment configuration
    # ./comfywm.nix # configuration for the comfy window manager
    ./services.nix # configuration for the wayland services
  ];
}
