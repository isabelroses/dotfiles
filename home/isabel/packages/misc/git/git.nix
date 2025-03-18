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
    userName = "isabel";
    userEmail = "isabel" + "@" + "isabelroses" + "." + "com"; # obsfuscate email to prevent webscrapper spam

    includes = [
      {
        condition = "gitdir:~/dev/uni/";
        inherit (osConfig.age.secrets."uni-gitconf") path;
      }
      {
        condition = "gitdir:~/Dev/uni/";
        inherit (osConfig.age.secrets."uni-gitconf") path;
      }
    ];

    lfs = {
      enable = true;
      skipSmudge = true; # we don't want another ctp/userstyles situation
    };

    # git commit signing
    signing = {
      key = cfg.signingKey;
      format = "openpgp";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      repack.usedeltabaseoffset = "true";
      color.ui = "auto";
      help.autocorrect = 10; # 1 second warning to a typo'd command

      diff = {
        algorithm = "histogram"; # a much better diff
        colorMoved = "plain"; # show moved lines in a different color
        mnemonicprefix = true;
      };

      core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";

      # nice quality of life improvements
      branch = {
        autosetupmerge = "true";

        # sorts branches so the newst ones by latest commit are at the top
        sort = "committerdate";
      };

      commit.verbose = true;

      # prune branches that are no longer on the remote
      fetch.prune = true;

      pull = {
        # the default functionality is to push the current branch that i am on to the remote
        default = "current";

        # equivalent to --ff-only
        ff = "only";
      };

      # if a remote does not have a branch that i have, create it
      push.autoSetupRemote = true;

      # nicer diffing for merges
      merge = {
        stat = "true";
        conflictstyle = "zdiff3";
        tool = "meld";
      };

      rebase = {
        # https://andrewlock.net/working-with-stacked-branches-in-git-is-easier-with-update-refs/
        updateRefs = true;

        autoSquash = true;
        autoStash = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # prevent data corruption
      transfer.fsckObjects = true;
      fetch.fsckObjects = true;
      receive.fsckObjects = true;
    };
  };
}
