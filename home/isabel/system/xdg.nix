{
  lib,
  config,
  pkgs,
  ...
}: let
  # browser = ["chromium.desktop"];
  browser = ["Schizofox"];
  zathura = ["org.pwmt.zathura"];
  filemanager = ["thunar"];

  associations = builtins.mapAttrs (_: v: (map (e: "${e}.desktop") v)) {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "audio/*" = ["mpv"];
    "video/*" = ["mpv"];
    "image/*" = ["viewnoir"];
    "application/json" = browser;
    "application/pdf" = zathura;
    "x-scheme-handler/spotify" = ["spotifyp"];
    "x-scheme-handler/discord" = ["Discord"];
    "inode/directory" = filemanager;
  };

  template = import lib.template.xdg "home-manager";
in {
  home.packages = with pkgs; [xdg-utils];
  xdg = {
    enable = true;

    userDirs = {
      enable = true;

      createDirectories = true;
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      videos = "$HOME/media/videos";
      music = "$HOME/media/music";
      pictures = "$HOME/media/pictures";
      desktop = "$HOME/desktop";
      publicShare = "$HOME/public/share";
      templates = "$HOME/public/templates";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        XDG_DEV_DIR = "$HOME/dev";
      };
    };

    mimeApps = {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };

    configFile = {
      "npm/npmrc" = template.npmrc;
      "python/pythonrc" = template.pythonrc;
    };
  };
}
