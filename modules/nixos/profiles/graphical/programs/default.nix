{
  imports = [
    ./ccache.nix # ccache lets us get more cache hits :D
    ./cli.nix # misc cli applications
    ./gui.nix # misc gui applications
    ./wine.nix # wine the emulator

    ./cosmic.nix # the cosmic desktop environment
    ./hyprland.nix # hyprland specific environment configuration
    # ./comfywm.nix # configuration for the comfy window manager
  ];
}
