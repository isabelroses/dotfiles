{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkIf mkAfter;

  inherit (config.garden.programs.defaults) shell;
in
{
  config = mkIf config.garden.profiles.workstation.enable {
    programs.zsh = {
      initContent =
        mkAfter
          # zsh
          ''
            function _fn_tmux_session() {
              name="''${1:-$(basename $PWD)}"
              tmux new-session -s ''${name}
            }
            function _fn_tmux_start() {
              spath=''${1:-$PWD}
              tmux new-session -s "$(basename $spath)" -c "$(realpath $spath)"
            }
            function _fn_tmux_attach() {
              if [[ -n "$1" ]]; then
                tmux attach -t "$1"
              else
                tmux attach
              fi
            }

            function _fn_tmux_fzf_sessions() {
              name=$(tmux ls -F "#S" | fzf)
              [[ -z "$name" ]] || _fn_tmux_attach "$name";
            }
            function _fn_tmux_fzf_dev() {
              dir="$(realpath ''${1:-''${XDG_DEV_DIR}})"
              spath=$(find "$dir" -mindepth 1 -maxdepth 1 -type d | fzf)
              [[ -z "$spath" ]] || _fn_tmux_start "$spath"
            }
          '';

      shellAliases = {
        tms = "_fn_tmux_session";
        tmsa = "_fn_tmux_start";
        tml = "tmux list-sessions";
        tma = "_fn_tmux_attach";
        tmat = "tmux attach -t";
        ts = "tmux split-window -c \"#{pane_current_path}\" -p 20 \"make test; read\"";

        tmla = "_fn_tmux_fzf_sessions";
        tmds = "_fn_tmux_fzf_dev";
      };
    };

    programs.tmux = {
      enable = true;

      prefix = "M-p";
      keyMode = "vi";
      reverseSplit = true;
      mouse = true;
      shell = "/run/current-system/sw/bin/${shell}";

      plugins = [
        {
          plugin = pkgs.tmuxPlugins.tmux-fzf;
          extraConfig = ''
            TMUX_FZF_LAUNCH_KEY="space"
          '';
        }
      ];

      extraConfig = # tmux
        ''
          # vim esc key delay fix

          set -sg escape-time 1

          # better session switching

          bind -n M-. switch-client -p
          bind -n M-, switch-client -n

          # better window switching

          bind -n S-Left previous-window
          bind -n S-Right next-window

          bind-key '"' command-prompt -I "#{session_name}" "rename-session -- '%%'"

          bind-key w display-popup -E -w 80% -h 80% -d "#{pane_current_path}"

          bind-key e split-window -l 16 -c "#{pane_current_path}"
          bind-key E split-window -c "#{pane_current_path}" -l 16 "make test; read"

          set -g status-style bg=default

          set -g set-titles on
          set -g set-titles-string "#S :: #W │ #{pane_title}"

          set-option -g status-position bottom
          set-option -g status-justify left

          set-option -g status-style fg=default,bg=default

          # # Left side of status bar
          # set-option -g status-left-length 100
          # set-option -g status-left ""
          #
          # # Window status
          # set-option -g window-status-format "#[fg=colour15,bg=default] #I · #W "
          # set-option -g window-status-current-format "#[fg=white,bg=colour8] #I · #W "
          # set-option -g window-status-separator ""
          #
          # # Right side of status bar
          # set-option -g status-right-length 100
          # # set-option -g status-right "#[bg=default] %a, %d %b #[bg=default] %R "
          # set-option -g status-right '#[fg=black,bg=cyan] #S #[fg=default,bg=default]#[fg=colour15]#{?#{!=:#{b:session_path},#{session_name}}, #{b:session_path} ,}#[fg=default]#[fg=magenta] #{s/\$//:#{session_id}} / #{server_sessions} #[fg=black,bg=magenta] %I:%M %P '

          # pane border
          set-option -g pane-border-style bg=default
          set-option -g pane-border-style fg=colour8
          set-option -g pane-active-border-style bg=default
          set-option -g pane-active-border-style fg=colour8

          # # Pane number indicator
          # set-option -g display-panes-colour white
          # set-option -g display-panes-active-colour white

          set-option -g message-style 'fg=black bg=yellow'
        '';
    };
  };
}
