{
  pkgs,
  self,
  config,
  osConfig,
  ...
}:
{
  # pointer / cursor theming
  home.pointerCursor = {
    enable = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
    name = "Capitaine Cursors";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
    gtk.enable = true;
    # this adds extra deps, so lets only enable it on wayland
    x11.enable = !(self.lib.validators.isWayland osConfig);
    doticons.enable = false;
  };
}
