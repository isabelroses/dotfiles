system: let
  # copy paste done right
  XDG_CONFIG_HOME = "$HOME/.config";
  XDG_CACHE_HOME = "$HOME/.cache";
  XDG_DATA_HOME = "$HOME/.local/share";
  XDG_STATE_HOME = "$HOME/.local/state";
  XDG_BIN_HOME = "$HOME/.local/bin";
  XDG_RUNTIME_DIR = "/run/user/$UID";
in {
  # global env
  glEnv = {
    inherit XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_BIN_HOME XDG_RUNTIME_DIR;
    PATH = ["$XDG_BIN_HOME"];
  };

  sysEnv = {
    # desktop
    KDEHOME = "${XDG_CONFIG_HOME}/kde";
    XCOMPOSECACHE = "${XDG_CACHE_HOME}/X11/xcompose";
    ERRFILE = "${XDG_CACHE_HOME}/X11/xsession-errors";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";

    # programs
    GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
    LESSHISTFILE = "${XDG_DATA_HOME}/less/history";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    STEPPATH = "${XDG_DATA_HOME}/step";
    WAKATIME_HOME = "${XDG_CONFIG_HOME}/wakatime";
    INPUTRC = "${XDG_CONFIG_HOME}/readline/inputrc";
    PLATFORMIO_CORE_DIR = "${XDG_DATA_HOME}/platformio";
    DOTNET_CLI_HOME = "${XDG_DATA_HOME}/dotnet";
    MPLAYER_HOME = "${XDG_CONFIG_HOME}/mplayer";
    SQLITE_HISTORY = "${XDG_CACHE_HOME}/sqlite_history";

    # programming
    ANDROID_HOME = "${XDG_DATA_HOME}/android";
    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";
    JUPYTER_CONFIG_DIR = "${XDG_CONFIG_HOME}/jupyter";
    GOPATH = "${XDG_DATA_HOME}/go";
    M2_HOME = "${XDG_DATA_HOME}/m2";
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    NODE_REPL_HISTORY = "${XDG_DATA_HOME}/node_repl_history";
    NPM_CONFIG_CACE = "${XDG_CACHE_HOME}/npm";
    NPM_CONFIG_TMP = "${XDG_RUNTIME_DIR}/npm";
    NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/config";
    PYTHONSTARTUP =
      if system == "nixos"
      then "/etc/pythonrc"
      else "${XDG_CONFIG_HOME}/python/pythonrc";
  };

  npmrc.text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
  '';

  pythonrc.text = ''
    import os
    import atexit
    import readline
    from pathlib import Path

    if readline.get_current_history_length() == 0:

        state_home = os.environ.get("XDG_STATE_HOME")
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
}
