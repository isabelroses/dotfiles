{ pkgs, osConfig, ... }:
let
  cfg = osConfig.garden.programs.agnostic.git;
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "isabel";
    userEmail = "isabel" + "@" + "isabelroses" + "." + "com"; # obsfuscate email to prevent webscrapper spam

    lfs = {
      enable = true;
      skipSmudge = true; # we don't want another ctp/userstyles situation
    };

    signing = {
      key = cfg.signingKey;
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main"; # warning the AUR hates this
      repack.usedeltabaseoffset = "true";
      color.ui = "auto";
      diff.algorithm = "histogram"; # a much better diff
      help.autocorrect = 10; # 1 second warning to a typo'd command

      core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";

      branch = {
        autosetupmerge = "true";
        sort = "committerdate";
      };

      commit.verbose = true;

      fetch.prune = true;

      pull.ff = "only"; # equivalent to --ff-only

      push = {
        default = "current";
        followTags = true;
        autoSetupRemote = true;
      };

      merge = {
        stat = "true";
        conflictstyle = "zdiff3";
        tool = "meld";
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      diff.mnemonicprefix = true;

      # prevent data corruption
      transfer.fsckObjects = true;
      fetch.fsckObjects = true;
      receive.fsckObjects = true;
    };
  };
}
