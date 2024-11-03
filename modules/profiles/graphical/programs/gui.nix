{ config, ... }:
{
  programs = {
    # we need dconf to interact with gtk
    dconf.enable = true;

    # gnome's keyring manager
    seahorse.enable = true;

    # networkmanager tray uility, pretty useful actually
    nm-applet.enable = config.programs.waybar.enable;
  };
}
