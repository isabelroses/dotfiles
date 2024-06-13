{ pkgs, osConfig, ... }:
let
  cfg = osConfig.modules.programs.agnostic.git;
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

      # prevent data corruption
      transfer.fsckObjects = true;
      fetch.fsckObjects = true;
      receive.fsckObjects = true;

      url = {
        "https://github.com/".insteadOf = "github:";
        "ssh://git@github.com/".pushInsteadOf = "github:";
        "https://gitlab.com/".insteadOf = "gitlab:";
        "ssh://git@gitlab.com/".pushInsteadOf = "gitlab:";
        "https://aur.archlinux.org/".insteadOf = "aur:";
        "ssh://aur@aur.archlinux.org/".pushInsteadOf = "aur:";
        "https://git.sr.ht/".insteadOf = "srht:";
        "ssh://git@git.sr.ht/".pushInsteadOf = "srht:";
        "https://codeberg.org/".insteadOf = "codeberg:";
        "ssh://git@codeberg.org/".pushInsteadOf = "codeberg:";
        "https://git@git.isabelroses.com/".insteadOf = "me:";
        "ssh://git@git.isabelroses.com/".pushInsteadOf = "me:";
        "https://forgejo@git.auxolotl.org/".insteadOf = "aux:";
        "ssh://forgejo@git.auxolotl.org/".pushInsteadOf = "aux:";
      };
    };
  };
}
