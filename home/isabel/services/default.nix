_: {
  imports = [
    ./shared # services that should be enabled regardless
    ./wayland # services that are wayland-only
    #./x11 # services that are x11-only
  ];
}
