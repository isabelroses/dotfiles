system: let
  # copy paste done right
  XDG_DATA_HOME = "\$HOME/.local/share";
  XDG_CONFIG_HOME = "\$HOME/.config";
  XDG_CACHE_HOME = "\$HOME/.cache";
  #XDG_STATE_HOME = "\$HOME/.local/state";
  XDG_RUNTIME_DIR = "/run/user/\${UID}";
  #XDG_BIN_HOME = "\$HOME/.local/bin";
in {
  glEnv = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    PATH = ["\${XDG_BIN_HOME}"];
  };
  sysEnv = {
    ANDROID_HOME = "${XDG_DATA_HOME}/android";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    ERRFILE = "${XDG_CACHE_HOME}/X11/xsession-errors";
    GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";
    JUPYTER_CONFIG_DIR = "${XDG_CONFIG_HOME}/jupyter";
    KDEHOME = "${XDG_CONFIG_HOME}/kde";
    LESSHISTFILE = "${XDG_DATA_HOME}/less/history";
    NPM_CONFIG_CACHE = "${XDG_CACHE_HOME}/npm";
    NPM_CONFIG_TMP = "${XDG_RUNTIME_DIR}/npm";
    NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/config";
    PYTHONSTARTUP =
      if system == "nixos"
      then "/etc/pythonrc"
      else "${XDG_CONFIG_HOME}/python/pythonrc";
    STEPPATH = "${XDG_DATA_HOME}/step";
    #VSCODE_EXTENSIONS = "${XDG_DATA_HOME}/code/extensions";
    WAKATIME_HOME = "${XDG_DATA_HOME}/wakatime";
    XCOMPOSECACHE = "${XDG_CACHE_HOME}/X11/xcompose";
    INPUTRC = "${XDG_CONFIG_HOME}/readline/inputrc";
    GOPATH = "${XDG_DATA_HOME}/go";
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    NODE_REPL_HISTORY = "${XDG_DATA_HOME}/node_repl_history";
    PLATFORMIO_CORE_DIR = "${XDG_DATA_HOME}/platformio";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
    DOTNET_CLI_HOME = "${XDG_DATA_HOME}/dotnet";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = [
      "\${HOME}/.steam/root/compatibilitytools.d"
    ];
  };

  npmrc.text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    tmp=''${XDG_RUNTIME_DIR}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
  '';

  pythonrc.text = ''
    import os
    import atexit
    import readline
    history = os.path.join(os.environ['XDG_CACHE_HOME'], 'python_history')
    try:
        readline.read_history_file(history)
    except OSError:
        pass
    def write_history():
        try:
            readline.write_history_file(history)
        except OSError:
            pass
    atexit.register(write_history)
  '';
}
