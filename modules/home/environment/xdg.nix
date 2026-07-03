{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkForce;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

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

  associations' = lib.concatMapAttrs (
    _: val: lib.listToAttrs (lib.map (mt: lib.nameValuePair mt "${val.app}.desktop") val.mimeTypes)
  ) appsToAssoc;

  specifics = {
    "x-scheme-handler/spotify" = [ "spotify.desktop" ];
    "x-scheme-handler/discord" = [ "discord.desktop" ];
  };

  associations = associations' // specifics;

  cfg = config.xdg;
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

  # You can generate something like this using xdg-ninja
  home.sessionVariables = {
    # desktop
    KDEHOME = "${cfg.configHome}/kde";
    XCOMPOSECACHE = "${cfg.cacheHome}/X11/xcompose";
    ERRFILE = "${cfg.cacheHome}/X11/xsession-errors";
    WINEPREFIX = "${cfg.dataHome}/wine";

    # programs
    GNUPGHOME = mkForce "${cfg.dataHome}/gnupg";
    LESSHISTFILE = "${cfg.dataHome}/less/history";
    CUDA_CACHE_PATH = "${cfg.cacheHome}/nv";
    STEPPATH = "${cfg.dataHome}/step";
    WAKATIME_HOME = "${cfg.configHome}/wakatime";
    INPUTRC = "${cfg.configHome}/readline/inputrc";
    PLATFORMIO_CORE_DIR = "${cfg.dataHome}/platformio";
    DOTNET_CLI_HOME = "${cfg.dataHome}/dotnet";
    MPLAYER_HOME = "${cfg.configHome}/mplayer";
    SQLITE_HISTORY = "${cfg.cacheHome}/sqlite_history";

    # programming
    ANDROID_HOME = "${cfg.dataHome}/android";
    ANDROID_USER_HOME = "${cfg.dataHome}/android";
    GRADLE_USER_HOME = "${cfg.dataHome}/gradle";
    IPYTHONDIR = "${cfg.configHome}/ipython";
    JUPYTER_CONFIG_DIR = "${cfg.configHome}/jupyter";
    GOPATH = "${cfg.dataHome}/go";
    GOMODCACHE = "${cfg.cacheHome}/go/pkg/mod";
    M2_HOME = "${cfg.dataHome}/m2";
    CARGO_HOME = "${cfg.dataHome}/cargo";
    RUSTUP_HOME = "${cfg.dataHome}/rustup";
    STACK_ROOT = "${cfg.dataHome}/stack";
    STACK_XDG = 1;
    NODE_REPL_HISTORY = "${cfg.dataHome}/node_repl_history";
    NPM_CONFIG_CACHE = "${cfg.cacheHome}/npm";
    NPM_CONFIG_TMP = "/run/user/$UID/npm";
    NPM_CONFIG_USERCONFIG = "${cfg.configHome}/npm/config";
  };

  xdg.configFile = {
    "npm/npmrc".text = ''
      prefix=''${cfg.dataHome}/npm
      cache=''${cfg.cacheHome}/npm
      init-module=''${cfg.configHome}/npm/config/npm-init.js
    '';

    "python/pythonrc".text = ''
      import os
      import atexit
      import readline
      from pathlib import Path

      if readline.get_current_history_length() == 0:

          state_home = os.environ.get("state")
          if state_home is None:
              state_home = Path.home() / ".local" / "state"
          else:
              state_home = Path(state_home)

          history_path = state_home / "python_history"
          if history_path.is_dir():
              raise OSError(f"'{history_path}' cannot be a directory")

          history = str(history_path)

          try:
              readline.read_history_file(history)
          except OSError: # Non existent
              pass

          def write_history():
              try:
                  readline.write_history_file(history)
              except OSError:
                  pass

          atexit.register(write_history)
    '';
  };
}
