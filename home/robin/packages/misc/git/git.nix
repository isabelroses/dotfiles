{
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = config.garden.programs.git;
in
{
  programs.git = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;
    userName = "robin";
    userEmail = "comfysage" + "@" + "isabelroses" + "." + "com";

    signing = {
      format = "ssh";
      signByDefault = true;
    };

    extraConfig = {
      core.editor = config.garden.programs.defaults.editor;

      # Qol
      color.ui = "auto";

      diff = {
        algorithm = "histogram"; # a much better diff
        colorMoved = "plain"; # show moved lines in a different color
      };

      safe.directory = "*";
      # add some must-use flags
      pull.rebase = true;
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      merge.ff = "only";
      push.autoSetupRemote = true;

      user.signingkey = osConfig.age.secrets.keys-gh.path;
      # personal preference
      init.defaultBranch = "main";
      # prevent data corruption
      transfer.fsckObjects = true;
      fetch.fsckObjects = true;
      receive.fsckObjects = true;
    };
  };
}
