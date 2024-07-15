{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf mkForce;
  inherit (pkgs.stdenv) isLinux;

  browser = [
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/ftp"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ];

  code = [
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

  media = [
    "video/*"
    "audio/*"
  ];

  images = [ "image/*" ];

  associations =
    (lib.genAttrs code (_: [ "nvim.desktop" ]))
    // (lib.genAttrs media (_: [ "mpv.desktop" ]))
    // (lib.genAttrs images (_: [ "viewnoir.desktop" ]))
    // (lib.genAttrs browser (_: [ "chromium.desktop" ]))
    // {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "x-scheme-handler/spotify" = [ "spotify.desktop" ];
      "x-scheme-handler/discord" = [ "Discord.desktop" ];
      "inode/directory" = [ "thunar.desktop" ];
    };

  template = lib.template.xdg;
in
{
  home = {
    packages = mkIf isLinux [ pkgs.xdg-utils ];
    sessionVariables = mkForce template.sysEnv;
  };

  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = mkIf isLinux {
      enable = true;
      createDirectories = true;

      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      desktop = "${config.home.homeDirectory}/desktop";
      videos = "${config.home.homeDirectory}/media/videos";
      music = "${config.home.homeDirectory}/media/music";
      pictures = "${config.home.homeDirectory}/media/pictures";
      publicShare = "${config.home.homeDirectory}/public/share";
      templates = "${config.home.homeDirectory}/public/templates";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        XDG_DEV_DIR = "${config.home.homeDirectory}/dev";
      };
    };

    mimeApps = {
      enable = isLinux;
      associations.added = associations;
      defaultApplications = associations;
    };

    configFile = {
      "npm/npmrc" = template.npmrc;
      "python/pythonrc" = template.pythonrc;
    };
  };
}
