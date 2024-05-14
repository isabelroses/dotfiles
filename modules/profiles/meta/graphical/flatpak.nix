{
  # enable flatpak
  services.flatpak.enable = true;

  environment.sessionVariables.XDG_DATA_DIRS = [ "/var/lib/flatpak/exports/share" ];
}
