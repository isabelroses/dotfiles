{
  imports = [
    ./ccache.nix # ccache lets us get more cache hits :D
    ./cli.nix # misc cli applications
    ./gui.nix # misc gui applications
    ./thunar.nix # thunar the only file manager i have to configure at the system level
    ./wine.nix # wine the emulator

    ./cosmic.nix # the cosmic desktop environment
    ./hyprland.nix # hyprland specific environment configuration
    # ./comfywm.nix # configuration for the comfy window manager
  ];
}
