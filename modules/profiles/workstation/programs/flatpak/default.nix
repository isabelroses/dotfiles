_: {
  # enable flatpak
  services.flatpak.enable = false;

  environment.sessionVariables.XDG_DATA_DIRS = ["/var/lib/flatpak/exports/share"];
}
