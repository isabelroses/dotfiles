{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
in
{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      ffmpegthumbnailer
      # needed to extract files
      xarchiver
      ;

    # packages necessary for thunar thumbnails
    inherit (pkgs.xfce) tumbler;
  };

  programs = {
    # the thunar file manager
    # we enable thunar here and add plugins instead of in systemPackages
    thunar = mkIf config.garden.programs.gui.fileManagers.thunar.enable {
      enable = true;
      plugins = builtins.attrValues {
        inherit (pkgs.xfce) thunar-archive-plugin thunar-media-tags-plugin;
      };
    };

    # we need dconf to interact with gtk
    dconf.enable = true;

    # gnome's keyring manager
    seahorse.enable = true;

    # networkmanager tray uility, pretty useful actually
    nm-applet.enable = config.programs.waybar.enable;
  };
}
