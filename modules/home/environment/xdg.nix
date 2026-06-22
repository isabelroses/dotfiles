{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib.attrsets) nameValuePair listToAttrs;
  inherit (lib.modules) mkForce;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  template = self.lib.template.xdg;
  vars = template.user config.xdg;

  appsToAssoc = {
    browser = {
      app = "chromium-browser";
      mimeTypes = [
        "text/html"
        "application/pdf"
        "x-www-browser"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ];
    };

    code = {
      app = "nvim";
      mimeTypes = [
        "application/json"
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    };

    media = {
      app = "mpv";
      mimeTypes = [
        "video/*"
        "audio/*"
      ];
    };

    images = {
      app = "mpv";
      mimeTypes = [ "image/*" ];
    };

    fileManager = {
      app = "com.system76.CosmicFiles";
      mimeTypes = [ "inode/directory" ];
    };
  };

  associations' =
    appsToAssoc
    |> lib.concatMapAttrs (
      _: val: val.mimeTypes |> map (mt: nameValuePair mt "${val.app}.desktop") |> listToAttrs
    );

  specifics = {
    "x-scheme-handler/spotify" = [ "spotify.desktop" ];
    "x-scheme-handler/discord" = [ "discord.desktop" ];
  };

  associations = associations' // specifics;
in
{
  home.preferXdgDirectories = true;

  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = isLinux && config.garden.profiles.workstation.enable;
      createDirectories = true;
      setSessionVariables = true;

      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      desktop = "${config.home.homeDirectory}/desktop";
      videos = "${config.home.homeDirectory}/media/videos";
      music = "${config.home.homeDirectory}/media/music";
      pictures = "${config.home.homeDirectory}/media/pictures";
      publicShare = "${config.home.homeDirectory}/public/share";
      templates = "${config.home.homeDirectory}/public/templates";
      projects = "${config.home.homeDirectory}/dev";

      extraConfig = {
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/screenshots";
        DEV = "${config.home.homeDirectory}/dev";
      };
    };

    mimeApps = {
      enable = isLinux;
      associations.added = associations;
      defaultApplications = associations;
    };

    portal.enable = lib.mkForce false;
  };

  home.sessionVariables = vars // {
    GNUPGHOME = mkForce vars.GNUPGHOME;
  };

  xdg.configFile = {
    "npm/npmrc" = template.npmrc;
    "python/pythonrc" = template.pythonrc;
  };
}
