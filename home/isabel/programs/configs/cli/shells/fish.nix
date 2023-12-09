{
  defaults,
  osConfig,
  lib,
  ...
}: let
  inherit (lib) optionalString;
in {
  programs.fish = {
    enable = true;
    catppuccin.enable = true;
    plugins = [];

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
    };
    shellAbbrs = {};

    shellInit = ''
      set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
      ${optionalString (osConfig.modules.device != "server") ''
        set TERMINAL ${defaults.terminal}
        export GPG_TTY=$(tty)
      ''};

      ${optionalString (osConfig.modules.device == "server") ''
        set TERMINAL dumb
        set TERM dumb
      ''};

      # themeing
      set fish_greeting
      export "MICRO_TRUECOLOR=1"
      starship init fish | source
      set -g theme_display_date no
      set -g theme_nerd_fonts yes
      set -g theme_newline_cursor yes
    '';
  };
}
