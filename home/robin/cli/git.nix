{
  lib,
  pkgs,
  self,
  config,
  ...
}:
let
  inherit (lib) mkIf mkMerge map;
  inherit (self.lib) giturl;
  inherit (lib.hm.dag) entryBefore;

  cfg = config.programs.git;
in
{
  config = mkIf cfg.enable (mkMerge [
    (mkIf config.garden.profiles.workstation.enable {
      garden.packages = {
        inherit (pkgs)
          gist # manage github gists
          # act # local github actions - littrally does not work
          gitflow # Extend git with the Gitflow branching model
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
      programs.git = {
        package = pkgs.gitMinimal;
        userName = "robin";
        userEmail = "comfysage" + "@" + "isabelroses" + "." + "com";

        signing = {
          format = "ssh";
          signByDefault = true;
        };

        delta = {
          enable = true;

          options = {
            navigate = true;
            side-by-side = true;
            line-numbers = true;
          };
        };

        aliases = {
          index = "status -s";
          graph = "log --oneline --graph";
          ahead = "!git log --oneline @{u}..HEAD | grep -cE '.*'";

          changelog = "-c pager.show=false show --format=' - %C(yellow)%h%C(reset) %<(80,trunc)%s' -q @@{1}..@@{0}";
          amend = "commit --amend";

          fpush = "push --force-with-lease";

          # stash
          spush = "stash push -a";
          spop = "stash pop -q";
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

          # ide residue
          ".idea/"
          ".vscode/"

          # dependencies
          ".direnv/"
          "node_modules"
          "vendor"
        ];

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

          user.signingkey = config.sops.secrets.keys-gh.path;
          # personal preference
          init.defaultBranch = "main";
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
                alias = "izzy";
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
