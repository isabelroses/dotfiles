# XDG settings
{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [ xdg-utils ];
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;

      download = "$HOME/downloads";
      desktop = "$HOME/desktop";
      documents = "$HOME/documents";

      publicShare = "$HOME/etc/public";
      templates = "$HOME/etc/templates";

      music = "$HOME/media/music";
      pictures = "$HOME/media/pictures";
      videos = "$HOME/media/videos";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = ["chromium.desktop"];
        "image/png" = ["chromium.desktop"];
      };
    };
  };
}