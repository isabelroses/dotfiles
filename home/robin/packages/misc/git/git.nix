{
  lib,
  osConfig,
  ...
}:
let
  inherit (lib.modules) mkIf;
  cfg = osConfig.garden.programs.git;
in
{
  programs.git = mkIf cfg.enable {
    enable = true;
    inherit (cfg) package;
    userName = "comfysage";
    userEmail = "67917529+comfysage@users.noreply.github.com";

    extraConfig = {
      core.editor = osConfig.garden.programs.defaults.editor;

      # Qol
      color.ui = "auto";
      diff.algorithm = "histogram"; # a much better diff
      safe.directory = "*";
      # add some must-use flags
      pull.rebase = true;
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      merge.ff = "only";
      push.autoSetupRemote = true;

      commit.gpgsign = true;
      gpg.format = "ssh";
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
