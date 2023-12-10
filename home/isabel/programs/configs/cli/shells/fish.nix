{
  defaults,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionalString getExe isModernShell;
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
        set -gx TERMINAL ${defaults.terminal}
      ''};

      ${optionalString (osConfig.modules.device == "server") ''
        set -gx TERMINAL dumb
      ''};

      ${optionalString (isModernShell osConfig) ''
        ${getExe pkgs.starship} init fish | source
      ''};

      ${getExe pkgs.nix-your-shell} fish | source

      switch $TERM
          case '*xte*'
            set -gx TERM xterm-256color
          case '*scree*'
            set -gx TERM screen-256color
          case '*rxvt*'
            set -gx TERM rxvt-unicode-256color
      end


      # themeing
      set fish_greeting
      export "MICRO_TRUECOLOR=1"
      set -g theme_display_date no
      set -g theme_nerd_fonts yes
      set -g theme_newline_cursor yes
    '';
  };
}
