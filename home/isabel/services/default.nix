_: {
  imports = [
    ./shared # Always on services
    ./wayland # wayland-only services
    #./x11 # x11-only services

    ./nix-index.nix
  ];
}
