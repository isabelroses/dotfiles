{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.strings) optionalString;
in
{
  sops = {
    secrets.env = { };

    templates.fish-env = {
      content = ''
        function setup_secrets_vars;
          if [ -n "$__SECRETS_SOURCED" ]
            return
          end
          set -gx __SECRETS_SOURCED '1'
          ${config.sops.placeholder.env}
        end
        setup_secrets_vars
      '';

      path = "${config.home.homeDirectory}/.config/fish/conf.d/sops-env.fish";
    };
  };

  home.shell.enableFishIntegration = false;

  programs.fish = {
    plugins = [ ];

    shellAliases = {
      mkdir = "mkdir -pv"; # always create pearent directory
      df = "df -h"; # human readblity
      rs = "systemctl reboot";
      jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
      # lg = "lazygit";
    };

    functions = {
      bj = "nohup $argv </dev/null &>/dev/null &";

      "." = ''
        set -l input $argv[1]
        if echo $input | grep -q '^[1-9][0-9]*$'
          set -l levels $input
          for i in (seq $levels)
            cd ..
          end
        else
          echo "Invalid input format. Please use '<number>' to go back a specific number of directories."
        end
      '';

      lg = ''
        set -x LAZYGIT_NEW_DIR_FILE /home/isabel/.cache/lazygit/newdir
        command lazygit $argv
        if test -f $LAZYGIT_NEW_DIR_FILE
          cd (cat $LAZYGIT_NEW_DIR_FILE)
          rm -f $LAZYGIT_NEW_DIR_FILE
        end
      '';
    };

    loginShellInit = optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      fish_add_path --move --prepend --path $HOME/.nix-profile/bin /run/wrappers/bin /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin 
    '';

    shellInit = ''
      # themeing
      set fish_greeting
      set -g theme_display_date no
      set -g theme_nerd_fonts yes
      set -g theme_newline_cursor yes
    '';
  };

  # generate each tool's shell integration at build time and drop it into a
  # conf.d file, rather than running the tool on every interactive shell startup.
  # each mkCmd just emits its integration to stdout; the wrapper guards it behind
  # `status is-interactive` so it only loads in interactive shells, matching where
  # these used to live in config.fish.
  xdg.configFile =
    lib.mapAttrs'
      (
        name: mkCmd:
        lib.nameValuePair "fish/conf.d/${name}.fish" {
          source =
            pkgs.runCommand "${name}-fish-config.fish"
              {
                nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ];
              }
              ''
                {
                  echo 'status is-interactive; and begin'
                  ${mkCmd config.programs.${name}}
                  echo # ensure the closing `end` lands on its own line
                  echo end
                } > "$out"
              '';
        }
      )
      {
        atuin = cfg: ''
          ${lib.getExe cfg.package} init fish ${lib.escapeShellArgs cfg.flags}
        '';

        fzf = cfg: ''
          ${lib.getExe cfg.package} --fish
        '';

        zoxide = cfg: ''
          ${lib.getExe cfg.package} init fish ${lib.concatStringsSep " " cfg.options}
        '';

        starship = cfg: ''
          echo 'if test "$TERM" != "dumb"'
          ${lib.getExe cfg.package} init fish
          echo # starship's init emits no trailing newline, so terminate it
          echo end
        '';

        nix-your-shell = cfg: ''
          ${lib.getExe cfg.package} fish
        '';

        direnv = cfg: ''
          echo 'if not functions -q __direnv_export_eval'
          ${lib.getExe cfg.package} hook fish
          echo end
        '';
      };
}
