_: {
  imports = [
    ./wayland # services that are wayland-only
    ./x11 # services that are x11-only
    ./shared # services that should be enabled regardless
  ];
}
