{config, ...}: let
  browser = ["chromium.desktop"];
  zathura = ["org.pwmt.zathura.desktop.desktop"];
  filemanager = ["thunar.desktop"];

  associations = {
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

    "audio/*" = ["mpv.desktop"];
    "video/*" = ["mpv.dekstop"];
    "image/*" = ["imv.desktop"];
    "application/json" = browser;
    "application/pdf" = zathura;
    "x-scheme-handler/spotify" = ["spotify.desktop"];
    "x-scheme-handler/discord" = ["Discord.desktop"];
    "inode/directory" = filemanager;
  };
in {
  xdg = {
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
  };
}
