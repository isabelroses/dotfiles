_: {
  # enable flatpak, as well as xdgp to communicate with the host filesystems
  services.flatpak.enable = false;

  environment.sessionVariables = {
    "XDG_DATA_DIRS" = [
      "$XDG_DATA_HOME/flatpak/exports/share"
    ];
  };
}
