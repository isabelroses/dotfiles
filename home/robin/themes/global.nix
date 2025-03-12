{
  pkgs,
  self,
  config,
  osConfig,
  ...
}:
{
  # pointer / cursor theming
  config.home.pointerCursor = {
    enable = pkgs.stdenv.hostPlatform.isLinux && config.garden.programs.gui.enable;
    name = "Capitaine Cursors";
    package = pkgs.capitaine-cursors-themed;
    size = 24;
    dotIcons.enable = false;
    gtk.enable = true;
    # this adds extra deps, so lets only enable it on wayland
    x11.enable = !(self.lib.validators.isWayland osConfig);
  };
}
