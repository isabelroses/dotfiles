{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf mkMerge map;
  inherit (lib.hm.dag) entryBefore;
  inherit (self.lib) giturl;
in
{
  config = mkIf config.programs.git.enable (mkMerge [
    (mkIf config.garden.profiles.workstation.enable {
      garden.packages = {
        inherit (pkgs)
          # gist # manage github gists
          # act # local github actions - littrally does not work
          # gitflow # Extend git with the Gitflow branching model
          cocogitto # git helpers
          ;
      };
    })

    # `programs.git` will generate the config file: ~/.config/git/config
    # to make git use this config file, `~/.gitconfig` should not exist!
    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      home.activation = {
        removeExistingGitconfig = entryBefore [ "checkLinkTargets" ] ''
          rm -f ~/.gitconfig
        '';
      };
    })

    {
      sops.secrets.uni-gitconf = { };

      programs.git = {
        package = pkgs.gitMinimal;
        userName = "isabel";
        userEmail = "isabel" + "@" + "isabelroses" + "." + "com"; # obsfuscate email to prevent webscrapper spam

        includes = [
          {
            condition = "gitdir:~/dev/uni/";
            inherit (config.sops.secrets."uni-gitconf") path;
          }
          {
            condition = "gitdir:~/Dev/uni/";
            inherit (config.sops.secrets."uni-gitconf") path;
          }
        ];

        lfs = {
          enable = true;
          skipSmudge = true; # we don't want another ctp/userstyles situation
        };

        # git commit signing
        signing = {
          format = "openpgp";
          signByDefault = true;
        };

        aliases = {
          st = "status";
          br = "branch";
          c = "commit -m";
          ca = "commit -am";
          co = "checkout";
          d = "diff";
          df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
          fuck = "commit --amend -m";
          graph = "log --all --decorate --graph";
          ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
          pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
          af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
          hist = ''
            log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all
          '';
          llog = ''
            log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative
          '';
          # https://github.com/arichtman/nix/blob/18f5613c2842e12e49350aeceace63863ad59244/modules/home/default-home/default.nix#L11
          fuggit = "!git add . && git commit --amend --no-edit && git push --force";
          # thanks @vbde for this
          idc = "!git commit -am '$(curl -s https://whatthecommit.com/index.txt)'";
        };

        ignores = [
          # system residue
          ".cache/"
          ".DS_Store"
          ".Trashes"
          ".Trash-*"
          "*.bak"
          "*.swp"
          "*.swo"
          "*.elc"
          ".~lock*"

          # build residue
          "tmp/"
          "target/"
          "result"
          "result-*"
          "*.exe"
          "*.exe~"
          "*.dll"
          "*.so"
          "*.dylib"

          # dependencies
          ".direnv/"
          "node_modules"
          "vendor"
        ];

        # pager / diff tool
        delta = {
          enable = true;

          options = {
            navigate = true;
            side-by-side = true;
            line-numbers = true;
          };
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

          url = mkMerge (
            map giturl [
              {
                domain = "github.com";
                alias = "github";
              }
              {
                domain = "gitlab.com";
                alias = "gitlab";
              }
              {
                domain = "aur.archlinux.org";
                alias = "aur";
                user = "aur";
              }
              {
                domain = "git.sr.ht";
                alias = "srht";
              }
              {
                domain = "codeberg.org";
                alias = "codeberg";
              }
              {
                domain = "git.isabelroses.com";
                alias = "me";
                port = 2222;
              }
              {
                domain = "git.auxolotl.org";
                alias = "aux";
                user = "forgejo";
              }
            ]
          );
        };
      };
    }
  ]);
}
