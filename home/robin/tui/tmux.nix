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
              spath=$(fd --absolute-path --base-directory=$dir --no-ignore '^.git$' | awk -F '.git/' '{print $1}' | fzf)
              [[ -z "$spath" ]] || _fn_tmux_start "$spath"
            }
            function _fn_tmux_zoxide() {
              [[ -z "$1" ]] && return
              _fn_tmux_start "$(zoxide query "$1")"
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
        tmza = "_fn_tmux_zoxide";
      };
    };

    evergarden.tmux.extraConfig = ''
      set -gq @window_left_separator ""
      set -gq @window_right_separator ""
    '';

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
          bind-key r source-file ~/.config/tmux/tmux.conf \; \
              display-message "source-file done"

          # vim esc key delay fix

          set -sg escape-time 1

          bind-key a choose-window

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

          # Left side of status bar
          set-option -g status-left-length 100
          # set-option -g status-left ""

          # Window status
          # set-option -g window-status-format "#[fg=#{@thm_overlay1},bg=#{@thm_surface0}] #I · #W "
          # set-option -g window-status-current-format "#[fg=#{@thm_subtext1},bg=#{@thm_surface0}] #I · #W "
          # set-option -g window-status-separator ""

          # Right side of status bar
          set-option -g status-right-length 100
          # # set-option -g status-right "#[bg=default] %a, %d %b #[bg=default] %R "
          # set-option -g status-right '#[fg=black,bg=cyan] #S #[fg=default,bg=default]#[fg=colour15]#{?#{!=:#{b:session_path},#{session_name}}, #{b:session_path} ,}#[fg=default]#[fg=magenta] #{s/\$//:#{session_id}} / #{server_sessions} #[fg=black,bg=magenta] %I:%M %P '
          # set-option -g status-right '#[fg=#{@thm_subtext1},bg=#{@thm_surface0}] #S#{?#{!=:#{b:session_path},#{session_name}}, · #{b:session_path},} #[fg=#{@thm_crust},bg=#{@thm_pink}] %I:%M %P '

          # pane border
          set-option -g pane-border-style bg=default,fg=colour8
          set-option -g pane-active-border-style bg=default,fg=colour8
        '';
    };
  };
}
